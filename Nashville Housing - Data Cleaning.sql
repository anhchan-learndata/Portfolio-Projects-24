/*

Cleaning Data in SQL Queries

*/

Select *
From DataCleaningProject..NashvilleHousing

	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT
/*Select SaleDate, CAST(SaleDate AS DATE)
From DataCleaningProject..NashvilleHousing
Update NashvilleHousing
Set SaleDate = CAST(SaleDate AS DATE)*/
-- This does not update the table because UPDATE does not change data types. The table is actually updating, but the data type for the column SaleDate is still datetime. 


-- Add and update the new column
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
Update NashvilleHousing
Set SaleDateConverted = CAST(SaleDate AS DATE)

-- Drop the old column
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate 

-- Select the new column
Select SaleDateConverted
From DataCleaningProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA (There are NULL values)
-- Owner address could be changed but Property address 99% will stay the same. Thus column property address could be populated if we had a reference point

-- If a ParcelID has a property address, then for the same ParcelID where the property address is null, we will populate it with the corresponding property address.

-- Join the same exact table to itself, where the ParcelID is the same but it's not the same row
Select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress, t2.PropertyAddress)
From DataCleaningProject..NashvilleHousing t1
Join DataCleaningProject..NashvilleHousing t2
	ON t1.ParcelID=t2.ParcelID
	AND t1.[UniqueID ]<>t2.[UniqueID ]
Where t1.PropertyAddress is NULL

Update t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
From DataCleaningProject..NashvilleHousing t1
Join DataCleaningProject..NashvilleHousing t2
	ON t1.ParcelID=t2.ParcelID
	AND t1.[UniqueID ]<>t2.[UniqueID ]
Where t1.PropertyAddress is NULL


--------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- SPLIT ADDRESS COLUMNS INTO INDIVIDUAL COLUMNS (Address, City, State)

-- Split Property Address using Substring and Charindex
Select Substring(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) As Address,
	   Substring(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, len(PropertyAddress)) As City
From DataCleaningProject..NashvilleHousing

--Add 2 new separate columns for Property Address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, len(PropertyAddress))




-- Split Owner Address using PARSENAME
Select 
	PARSENAME(Replace(OwnerAddress, ',', '.'),3) ,
	PARSENAME(Replace(OwnerAddress, ',', '.'),2),
	PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From NashvilleHousing

-- Add 3 new separate columns for Owner Address
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHANGE Y AND N TO YES AND NO IN "Sold as Vacant" FIELD
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaningProject..NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant,
	   CASE SoldAsVacant 
	   When 'No' Then 'N'
	   When 'N' Then 'N'
	   Else 'Y'
	   END AS NewSoldAsVacant
From DataCleaningProject..NashvilleHousing

Update DataCleaningProject..NashvilleHousing
SET SoldAsVacant = CASE  
				   When SoldAsVacant='No' Then 'N'
				   When SoldAsVacant='N' Then 'N'
				   Else 'Y'
				   END;
-- I misread the task. The previous queries were to change Yes/No to Y/N

Update DataCleaningProject..NashvilleHousing
SET SoldAsVacant = CASE  
				   When SoldAsVacant='N' Then 'No'
				   Else 'Yes'
				   END;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES
-- Note: It's not a standard practice to delete data in database
-- Use CTE and window functions to find duplicates value and delete them from the CTE
-- We need to partition it on things that should be unique to each row

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER()OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference
	ORDER BY UniqueID
	) row_num
From NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num>1
-- There's turn out to be 104 duplicates

	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS (PropertyAddress, OwnerAddress, TaxDistrict)
-- Note: Don't do this to the raw data that you imported - legal advice
-- This happens more when working with View

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

Select *
From NashvilleHousing








--------------------------------------------------------------------------









