/* Data cleaning & exploration project with Nashville Houses dataset */

------Data preview------
SELECT 
  TOP (1000) *
FROM 
  [Nashville Housing Data]

------Total number of records------
SELECT 
    COUNT(*)
FROM [Nashville Housing Data]

-------Populate Property Address data------
SELECT 
  *
FROM 
  [Nashville Housing Data]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

/*Some of the property addresses are missing. However, each ParcelID had its unique address that we can use to fill into the missing fields*/
SELECT 
  a.ParcelID, 
  a.PropertyAddress, 
  b.ParcelID, 
  b.PropertyAddress, 
  ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM 
  [Nashville Housing Data] a 
  JOIN [Nashville Housing Data] b ON a.ParcelID = b.ParcelID 
  AND a.UniqueID <> b.UniqueID 
WHERE 
  a.PropertyAddress IS NULL

/*Updating the PropertyAddress by filling null values*/
UPDATE 
  a 
SET 
  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM 
  [Nashville Housing Data] a 
  JOIN [Nashville Housing Data] b ON a.ParcelID = b.ParcelID 
  AND a.UniqueID <> b.UniqueID 
WHERE 
  a.PropertyAddress IS NULL

--Looking at the data
SELECT 
  *
FROM 
  [Nashville Housing Data]
WHERE PropertyAddress IS NULL

------Splitting out PropertyAddress into individual columns (Address, City, State) with SUBSTRING and CHARINDEX function------

/*Using substring we are fetching the address and city from Property Address*/
SELECT 
  PropertyAddress, 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City 
FROM 
  [Nashville Housing Data]


/*Adding and updating 2 columns with the values of Property address and property city*/
ALTER TABLE
  [Nashville Housing Data] 
ADD 
  PropertySplitAddress NVARCHAR(255);
UPDATE 
  [Nashville Housing Data] 
SET 
  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE 
  [Nashville Housing Data] 
ADD 
  PropertySplitCity NVARCHAR(255);
UPDATE 
  [Nashville Housing Data] 
SET 
  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM 
  [Nashville Housing Data]

------Splitting out OwnerAddress into Individual Columns (Address, City, State) with PARSENAME function------
SELECT
   OwnerAddress 
FROM
   [Nashville Housing Data] 

SELECT
  OwnerAddress,
  PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3 ),
  PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2 ),
  PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1 ) 
FROM
  [Nashville Housing Data]

/* Adding 3 new columns */ 
ALTER TABLE [Nashville Housing Data] 
ADD 
  OwnerAddressSplit NVARCHAR(255), OwnerCity NVARCHAR(255), OwnerState NVARCHAR(255);

/*Updating those newly added columns with the values of Owner Address, City & State*/
UPDATE
   [Nashville Housing Data] 
SET
   OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

UPDATE
   [Nashville Housing Data] 
SET
   OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

UPDATE
   [Nashville Housing Data] 
SET
   OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT *
FROM 
  [Nashville Housing Data]

------Change Y and N to Yes and No in "Sold as vacant" field------
SELECT DISTINCT(SoldAsVacant), 
  COUNT(SoldASVacant)
FROM [Nashville Housing Data]
GROUP BY 
  SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant =  'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Nashville Housing Data]

UPDATE [Nashville Housing Data]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant =  'N' THEN 'No'
	ELSE SoldAsVacant
	END

SELECT *
FROM [Nashville Housing Data]

------Delete unused columns------
ALTER TABLE [Nashville Housing Data]
  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT * 
FROM 
  [Nashville Housing Data]
  
------Data Exploration to get some useful insights------

/* House Average value by year*/
SELECT 
  DISTINCT (YearBuilt), AVG(TotalValue) AS AverageValue
FROM 
  [Nashville Housing Data]
GROUP BY YearBuilt
ORDER BY YearBuilt DESC

/*Effect on total value by acreage*/

SELECT 
  Acreage, AVG(TotalValue) AS AvgValue
FROM 
  [Nashville Housing Data]
GROUP BY Acreage
ORDER BY Acreage DESC

/*Total Value vs Sold Value*/

SELECT SalePrice, TotalValue, (SalePrice - TotalValue) AS Difference
FROM [Nashville Housing Data]

/* Top 10 cities */
select Top 10 PropertySplitCity , count(PropertySplitCity) as total 
from [Nashville Housing Data] 
group by PropertySplitCity 
order by total desc;

/* Min, max and average sale price */
SELECT 
  MIN(SalePrice) AS Min_SalePrice,
  MAX(SalePrice) AS Max_Saleprice,
  ROUND(AVG(SalePrice),2) AS Average_Sale_Price 
FROM [Nashville Housing Data]

