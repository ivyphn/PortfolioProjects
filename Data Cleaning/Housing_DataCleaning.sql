-- Cleaning data using SQL

SELECT *
FROM dbo.NashvilleHousing

-- Standardise date format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT *
FROM dbo.NashvilleHousing

SELECT *
FROM dbo.NashvilleHousing

-- Populate property address data

SELECT *
FROM dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM dbo.NashvilleHousing

SELECT 
 PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END

-- Remove Duplicates 
WITH RowNumCTE AS
(
SELECT *
,	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY 
				 UniqueID
				 ) row_num 
FROM dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Remove Unused Column
SELECT *
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate














