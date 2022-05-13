/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM PortfolioProjects..NashvilleHouses

------------------------------------------------------------------------------------------------------
-- Standarize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProjects..NashvilleHouses

ALTER TABLE PortfolioProjects..NashvilleHouses
ADD SaleDateConverted Date;

UPDATE PortfolioProjects..NashvilleHouses 
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------------------------
--Populate Property Address data

SELECT *
FROM PortfolioProjects..NashvilleHouses
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHouses a
JOIN PortfolioProjects..NashvilleHouses b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHouses a
JOIN PortfolioProjects..NashvilleHouses b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


---------------------------------------------------------------------------------------------------------
--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHouses 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProjects..NashvilleHouses 

ALTER TABLE PortfolioProjects..NashvilleHouses
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProjects..NashvilleHouses 
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE PortfolioProjects..NashvilleHouses
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProjects..NashvilleHouses 
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProjects..NashvilleHouses 

SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHouses 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjects..NashvilleHouses 

ALTER TABLE PortfolioProjects..NashvilleHouses
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProjects..NashvilleHouses 
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProjects..NashvilleHouses
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProjects..NashvilleHouses 
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProjects..NashvilleHouses
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProjects..NashvilleHouses 
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortfolioProjects..NashvilleHouses

-----------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldASVacant)
FROM PortfolioProjects..NashvilleHouses
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant =  'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProjects..NashvilleHouses

UPDATE PortfolioProjects..NashvilleHouses
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant =  'N' THEN 'No'
	ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProjects..NashvilleHouses
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

DELETE
FROM RowNumCTE
WHERE row_num > 1


-------------------------------------------------------------------------------------
--Delete unused columns

SELECT * 
FROM PortfolioProjects..NashvilleHouses

 ALTER TABLE PortfolioProjects..NashvilleHouses
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate