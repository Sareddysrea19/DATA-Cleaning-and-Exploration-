
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Projects].[dbo].[NashvilleHousing]
  
  select * from [Projects].[dbo].[NashvilleHousing] where [UniqueID ] = 2045 


/*

Cleaning Data in SQL QUERIES

*/

select * from Projects..NashvilleHousing 



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Standardize Date Format

select SaleDate, CONVERT(Date,SaleDate) 
from Projects..NashvilleHousing

Select SaleDateConverted,CONVERT(Date,SaleDate) from Projects..NashvilleHousing 


Update NashvilleHousing SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update Properly

ALTER table NashvilleHousing add SaleDateConverted Date

Update NashvilleHousing SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted,CONVERT(Date,SaleDate) from Projects..NashvilleHousing 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address data

SELECT * From NashvilleHousing 
--where PropertyAddress is NUll
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Projects..NashvilleHousing a
Join Projects..NashvilleHousing b
	On  a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Projects..NashvilleHousing a
Join Projects..NashvilleHousing b
	On  a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, States) 

Select PropertyAddress From Projects.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select  PropertyAddress,
        SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
		SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)),
		CHARINDEX(',',PropertyAddress)
From Projects.dbo.NashvilleHousing
--(We can't seperate two values into from one column without creating two other columns)

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from NashvilleHousing
select PropertyAddress,PropertySplitAddress,PropertySplitCity from Projects..NashvilleHousing 

--OwnerAddress--
Select OwnerAddress from NashvilleHousing

Select OwnerAddress,
	   PARSENAME(replace(ownerAddress,',','.'), 1),
	   PARSENAME(replace(ownerAddress,',','.'), 2),
	   PARSENAME(replace(ownerAddress,',','.'),3)
from  NashvilleHousing

Alter Table Nashvillehousing Add OwnerSplitAddress Nvarchar(255)
Update Nashvillehousing Set OwnerSplitAddress = PARSENAME(replace(ownerAddress,',','.') 3) 

Alter Table Nashvillehousing Add OwnerSplitCity Nvarchar(255)
Update Nashvillehousing Set OwnerSplitCity = PARSENAME(replace(ownerAddress,',','.'),2)

Alter Table Nashvillehousing Add OwnerSplitState Nvarchar(255)
Update Nashvillehousing Set OwnerSplitState = PARSENAME(replace(ownerAddress,',' , '.'),1) 

select * from Projects..NashvilleHousing
select  OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState From Projects..NashvilleHousing 


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" fields

 select distinct(SoldAsVacant),Count(SoldAsVacant) 
 from Projects..NashvilleHousing
 group by SoldAsVacant
 order by 2


 Select SoldAsVacant, Case When SoldAsVacant = 'y' then 'Yes'
					       When SoldAsVacant = 'n' then 'No'
						   ELSE SoldAsVacant
						   END
 from Projects..NashvilleHousing

 Update NashvilleHousing 
 Set SoldAsVacant = Case When SoldAsVacant = 'y' then 'Yes'
			When SoldAsVacant = 'n' then 'No'
			ELSE SoldAsVacant
			END
			

select distinct(SoldAsVacant),Count(SoldAsVacant) 
from Projects..NashvilleHousing group by SoldAsVacant order by 2

-------------------------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

With RowNumCTE As(
SELECT *,row_number() over(partition by ParcelID,
                                        PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										order by UniqueID) row_num
FROM Projects..NashvilleHousing
--order by ParcelID
)
select  * from RowNumCTE Where row_num > 1 Order by PropertyAddress



With RowNumCTE As(
SELECT *,row_number() over(partition by ParcelID,
                                        PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										order by UniqueID) row_num
FROM Projects..NashvilleHousing
--order by ParcelID
Delete from RowNumCTE Where row_num > 1  ----(Deleting all duplicates records with CTE Condition) and then again check above select statement with CTE




select * from Projects..NashvilleHousing

----------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * from Projects.dbo.NashvilleHousing

Alter Table NashvilleHousing Drop Column OwnerAddress,TaxDistrict,PropertyAddress
Alter Table NashvilleHousing Drop Column SaleDate











---------------------------------------------------------------
---------------------------------------------------------------



-----------------------------------------------------------------------------
--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO







