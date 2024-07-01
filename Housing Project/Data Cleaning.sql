*

Cleaning Data in SQL Queries

*/

-- Standardize Date Format

select SaleDate, CONVERT(Date,SaleDate) as SaleDateUpdated
from Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashville_Housing_Data
ADD SaleDateConverted Date;

UPDATE Nashville_Housing_Data
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
From Nashville_Housing_Data


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT * 
FROM Nashville_Housing_Data
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT * 
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Nashville_Housing_Data

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD PropertySplitAddress Nvarchar(255)

UPDATE Nashville_Housing_Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville_Housing_Data
ADD PropertySplitCity Nvarchar(255)

UPDATE Nashville_Housing_Data
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Nashville_Housing_Data



-- OWNER ADDRESS

SELECT OwnerAddress
FROM Nashville_Housing_Data

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnerAddressConverted,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerState
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Nashville_Housing_Data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashville_Housing_Data
ADD OwnerSplitCity Nvarchar(255)

UPDATE Nashville_Housing_Data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville_Housing_Data
ADD OwnerSplitState Nvarchar(255)

UPDATE Nashville_Housing_Data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM Nashville_Housing_Data

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END 
FROM Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END 

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM Nashville_Housing_Data
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM Nashville_Housing_Data
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, TaxDistrict

SELECT * 
FROM Nashville_Housing_Data 

EXEC sp_rename 'Nashville_Housing_Data.OwnerSplitAddress','OwnerAddress'

