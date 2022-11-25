/*
Cleaning Data in SQL Queries
*/


Select *
From AditiJoshiPortfolio.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From AditiJoshiPortfolio.dbo.NashvilleHousing

ALTER TABLE AditiJoshiPortfolio.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update AditiJoshiPortfolio.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From AditiJoshiPortfolio.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From AditiJoshiPortfolio.dbo.NashvilleHousing a
JOIN AditiJoshiPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From AditiJoshiPortfolio.dbo.NashvilleHousing a
JOIN AditiJoshiPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From AditiJoshiPortfolio.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From AditiJoshiPortfolio.dbo.NashvilleHousing


ALTER TABLE AditiJoshiPortfolio.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update AditiJoshiPortfolio.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE AditiJoshiPortfolio.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update AditiJoshiPortfolio.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From AditiJoshiPortfolio.dbo.NashvilleHousing

Select Owneraddress
From AditiJoshiPortfolio.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',','.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)
From AditiJoshiPortfolio.dbo.NashvilleHousing

ALTER TABLE AditiJoshiPortfolio.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update AditiJoshiPortfolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)

ALTER TABLE AditiJoshiPortfolio.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update AditiJoshiPortfolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)


ALTER TABLE AditiJoshiPortfolio.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update AditiJoshiPortfolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)

Select *
From AditiJoshiPortfolio.dbo.NashvilleHousing

---------------------------------------------------------------------------
--Change Y and n to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From AditiJoshiPortfolio.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
 CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From AditiJoshiPortfolio.dbo.NashvilleHousing

Update AditiJoshiPortfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
                        When SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END

---------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
 
From AditiJoshiPortfolio.dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num = 1
Order By PropertyAddress

---------------------------------------------------------------------------

--Delete Unused Columns

Select *
From AditiJoshiPortfolio.dbo.NashvilleHousing


ALTER TABLE AditiJoshiPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE AditiJoshiPortfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate