-- Cleaning SQL Data

select *
FROM PortfolioProject1..NashvilleHousing 

-- Standardize Date Format: Remove Time Part

select SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject1..NashvilleHousing 

-- For some odd this this works in select statement but not in update as below)
--update PortfolioProject1..NashvilleHousing
--SET SaleDate = CONVERT(date, SaleDate)

-- So we'll create a separate column and later delete the SaleDate column

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject1..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);


-- Populate Property Address Data

select * 
FROM PortfolioProject1..NashvilleHousing
where PropertyAddress is NULL

-- Ordering by ParcelID we find that there are many repetitive Parcel IDs  with same  Address.
select * 
FROM PortfolioProject1..NashvilleHousing
ORDER BY ParcelID 

-- So Idea is to populate the NULL values with similar ParcelIDs addresses
-- For that we need to self JOIN the tables and find the PropertyAddress with NULL values

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID]
Where a.PropertyAddress is null


-- Updating the NULL values using self JOIN

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- BREAK UP of PropertyAddress into individual columns (StreetAddress, City)

select PropertyAddress
FROM PortfolioProject1.dbo.NashvilleHousing  -- we can see that address is separated by ,

--select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address   -- -1 to 
--,charindex(',',PropertyAddress)  -- returns value
--FROM PortfolioProject1.dbo.NashvilleHousing 

select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as StreetAddress,   -- -1 to 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as CityAddress -- +1 indicate taking the next character after ','
FROM PortfolioProject1.dbo.NashvilleHousing 


-- Creating 2 columns (PropertyStreetAddress & PropertyCityAddress) and adding that value in

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD PropertyStreetAddress nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD PropertyCityAddress nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress));



-- -- BREAK UP of OwnerAddress into individual columns (StreetAddress, City, State)
-- USING PARSENAME(column,search_start)  


select OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),3) as  OwnerStreetAddress,-- Also PARSENAME works reverse (R-L), so 1 would mean Right most cahacter till '.'
PARSENAME(Replace(OwnerAddress,',','.'),2) as  OwnerCityAddress,
PARSENAME(Replace(OwnerAddress,',','.'),1) as  OwnerStateAddress
FROM PortfolioProject1..NashvilleHousing


ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerStreetAddress nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerStreetAddress = PARSENAME(Replace(OwnerAddress,',','.'),3);

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerCityAddress nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerCityAddress = PARSENAME(Replace(OwnerAddress,',','.'),2);

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerStateAddress nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerStateAddress = PARSENAME(Replace(OwnerAddress,',','.'),1);



-- CHANGE Y or N to Yes or No in 'SoldAsVacant' column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) CountSoldAsVacant
FROM PortfolioProject1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject1..NashvilleHousing


UPDATE PortfolioProject1..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates: Using CTE & Widows Function
-- USING CTE to Query on a Query

WITH RemoveDuplicatesCTE AS (
select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID
	) AS RowNum
FROM PortfolioProject1..NashvilleHousing
--ORDER BY ParcelID
)
Select * from RemoveDuplicatesCTE
WHERE RowNum > 1
ORDER BY [UniqueID ] 

-- DELETE Duplicate Rows
WITH RemoveDuplicatesCTE AS (
select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID
	) AS RowNum
FROM PortfolioProject1..NashvilleHousing
--ORDER BY ParcelID
)
DELETE from RemoveDuplicatesCTE
WHERE RowNum > 1
-- ORDER BY [UniqueID ] 


-- DELETE Unused columns: Always take backup, DON'T DO THIS ON RAW DATA

select * from PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict