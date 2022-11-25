SELECT *
FROM AditiJoshiPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM AditiJoshiPortfolio..CovidVaccinations
--ORDER BY 3,4

--Selecting only useful information

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM AditiJoshiPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract the disease in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM AditiJoshiPortfolio..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows percentage of population that got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as infection_rate
FROM AditiJoshiPortfolio..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, 
 MAX(total_cases) as HighestInfectionCount, 
 MAX((total_cases/population)*100) as infection_rate
FROM AditiJoshiPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY infection_rate desc

--Showing the countries with highest death Count per population

SELECT location,
 MAX(cast(total_deaths as int)) as TotalDeathCount
FROM AditiJoshiPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with highest death count per population

SELECT continent, 
 MAX(cast(total_deaths as int)) as TotalDeathCount
FROM AditiJoshiPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases)as total_cases,
 SUM(CAST(new_deaths as int )) as total_deaths,
 SUM(CAST(new_deaths as int ))/SUM(new_cases) * 100 as DeathPercentage
FROM AditiJoshiPortfolio..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM AditiJoshiPortfolio..CovidDeaths dea
JOIN AditiJoshiPortfolio..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location,date, population, RollingPeopleVaccinated, new_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM AditiJoshiPortfolio..CovidDeaths dea
JOIN AditiJoshiPortfolio..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null

)
SELECT *,
(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
FROM PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT into #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM AditiJoshiPortfolio..CovidDeaths dea
JOIN AditiJoshiPortfolio..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null

SELECT *,
(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
FROM #PercentPeopleVaccinated


--Creating View to store data for later

CREATE VIEW PercentPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM AditiJoshiPortfolio..CovidDeaths dea
JOIN AditiJoshiPortfolio..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
