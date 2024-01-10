/* 

Cleaning Data in SQL Queries!

*/

SELECT * 
FROM NashProject..NashvilleHousing



--Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashProject..NashvilleHousing

ALTER TABLE NashProject..NashvilleHousing
ADD SalesDateConverted Date

UPDATE NashProject..NashvilleHousing
SET SalesDateConverted =  CONVERT(Date,SaleDate)


SELECT SalesDateConverted, CONVERT(Date,SaleDate)
FROM NashProject..NashvilleHousing

-----------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM NashProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress) 
--ISNULL(column that has null values, what column to fill it in with)
FROM NashProject..NashvilleHousing a
INNER JOIN NashProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashProject..NashvilleHousing a
INNER JOIN NashProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------

--Breaking out Address into seperate columns (Address, City, State)

SELECT PropertyAddress
FROM NashProject..NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City 
--SUSTRING(text you want to extract, start position, the number of characters to extract)
--CHAIRINDEX(the string you are looking for, string to be searched)
FROM NashProject..NashvilleHousing

ALTER TABLE NashProject..NashvilleHousing
ADD PropertySplitAddress varchar(255)

UPDATE NashProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashProject..NashvilleHousing
ADD PropertySplitCity varchar(255)

UPDATE NashProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT PropertySplitAddress, PropertySplitCity
FROM NashProject..NashvilleHousing


SELECT OwnerAddress
FROM NashProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS Address, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS City, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS State
FROM NashProject..NashvilleHousing
--PARSENAME(string or column name, which part you want to extract), it works backwards so 1 would be the last part
--REPLACE(string or column name, the string  you want to replace, the string new string)

SELECT * 
FROM NashProject..NashvilleHousing


ALTER TABLE NashProject..NashvilleHousing
ADD OwnerSplitAddress varchar(255)

UPDATE NashProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 

ALTER TABLE NashProject..NashvilleHousing
ADD OwnerSplitCity varchar(255)

UPDATE NashProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) 

ALTER TABLE NashProject..NashvilleHousing
ADD OwnerSplitState varchar(255)

UPDATE NashProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) 


-----------------------------------------------------------------------------------------------

--Change Y and N to yes and No in "SoldAsVacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, 
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashProject..NashvilleHousing

UPDATE NashProject..NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashProject..NashvilleHousing

-----------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNum AS(
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM NashProject..NashvilleHousing
)

SELECT * 
--DELETE
FROM RowNum
WHERE row_num > 1 



-----------------------------------------------------------------------------------------------
--Delete Unused Columns

ALTER TABLE NashProject..NashVilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE NashProject..NashVilleHousing
DROP COLUMN SaleDate

SELECT * 
FROM NashProject..NashVilleHousing
