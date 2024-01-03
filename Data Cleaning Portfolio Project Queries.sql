/*

Cleaning Data in SQL Queries

*/


select *
from NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format


select saledateconverted,convert(date,SaleDate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,saledate)


--If it doesn't Update properly


alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,saledate)


 --------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data


select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID,A.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing as a 
join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.ParcelID
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


select
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address, 
substring(propertyAddress  ,CHARINDEX(',',propertyAddress) +1,len(propertyAddress)) as Address
from NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update  NashvilleHousing
set PropertySplitCity = substring(propertyAddress  ,CHARINDEX(',',propertyAddress) +1,len(propertyAddress))


select *
from NashvilleHousing


select OwnerAddress
from NashvilleHousing


select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates


with RowNumCTE as(
select *,
		ROW_NUMBER() over (partition by parcelID,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										order by uniqueID)
										RowNum
from NashvilleHousing
--order by ParcelID
)
select * --delete 
from RowNumCTE
where RowNum > 1
order by PropertyAddress --order by PropertyAddress


select *
from NashvilleHousing


---------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


Select *
From NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
										