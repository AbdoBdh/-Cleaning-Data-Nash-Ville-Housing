---/*---

 --- Cleaning Data In SQL Querier

 ---/*---

 Select * 
 FROM dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------


--- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
 FROM dbo.NashvilleHousing

 Update NashvilleHousing
 Set SaleDate = CONVERT(Date,SaleDate)


 Alter Table NashvilleHousing
 Add SaleDateConverted Date;

 Update NashvilleHousing
 Set SaleDateConverted = CONVERT(Date,SaleDate)



---------------------------------------------------------------------------------------------------------------------------------------------


--- Populate Property Adress Data


Select *
FROM dbo.NashvilleHousing
Where PropertyAddress is null
Order By ParcelID




Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
 On a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null


 UPDATE a
 SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
 FROM dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
 On a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null


 




---------------------------------------------------------------------------------------------------------------------------------------------


--- Breaking Out Adress Into Individual Columns (Adress, City, State)

--- propertyAddress----------------------------------

Select propertyAddress
 FROM dbo.NashvilleHousing




 SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) As Address
FROM dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))


---- OwnerAddress------------------------------------------------------------

Select OwnerAddress
FROM dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



---------------------------------------------------------------------------------------------------------------------------------------------


--- Change Y And N To Yes And No In "Sold As Vacant" Field



Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
Group by SoldAsVacant
Order By 2


Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No' 
	  ELSE SoldAsVacant
	  END
FROM dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No' 
	  ELSE SoldAsVacant
	  END







-------------------------------------------------------------------------------------------------------------------------------------------


--- Remove Duplicates


WITH RowNumCTE AS(
Select *, 
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by UniqueID
			 ) Row_num
FROM dbo.NashvilleHousing
)
			 
SELECT *
From RowNumCTE
Where Row_num > 1
---Order by PropertyAddress








----------------------------------------------------------------------------------------------------------------------------------------------


--- Delete Unused Columns


Select * 
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict