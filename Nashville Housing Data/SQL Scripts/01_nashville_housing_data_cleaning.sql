/*

Cleaning Data in SQL

*/

-- Let us take a look into the data

select
	*
from
	Nashville_Housing..housing;
Go

-- Standardise the Date Column
-- The date column contains both date and time. We do not require the time data. We will create a new column with just the date.

select
	SaleDateNew, convert(date, SaleDate)
from
	Nashville_Housing..housing;

Alter table Nashville_Housing..housing
add SaleDateNew date;

update Nashville_Housing..housing
set SaleDateNew = convert(date, SaleDate)
GO


-- Populate Property Address Data
-- The property address is black for some rows. We need to populate the address in those rows. 
-- The Parcel ID is repeated in the table. The address of the property is linked to the Parcel ID i.e for a single Parcel ID the address will be the same.
-- The Unique ID, however, is unique to each row. We are going to use Unique ID to distinguish between the rows and populate the address based by copying from another row with the same Parcel ID.


select *
from Nashville_Housing..housing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing..housing a
join Nashville_Housing..housing b
on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Let us update the table with the above solution

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing..housing a
join Nashville_Housing..housing b
on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
GO



-- Breaking down the Address into Address, City & State etc.
-- reserved


select PropertyAddress
from Nashville_Housing..housing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as PropertyAddressNew,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as PropertyCity
from Nashville_Housing..housing



Alter table Nashville_Housing..housing
add PropertyAddressNew nvarchar(255);

update Nashville_Housing..housing
set PropertyAddressNew = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

Alter table Nashville_Housing..housing
add PropertyCity nvarchar(255);

update Nashville_Housing..housing
set PropertyCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))
GO

