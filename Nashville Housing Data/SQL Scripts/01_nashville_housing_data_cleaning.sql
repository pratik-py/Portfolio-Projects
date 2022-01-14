
/*

Cleaning Data in SQL

*/

-- Take a look into the data

SELECT *
FROM Nashville_Housing..housing;
GO

-- Standardise the Date Column
-- The date column contains both date and time. The time data is not required. Create a new column with just the date.

SELECT SaleDateNew, 
       CONVERT(DATE, SaleDate)
FROM Nashville_Housing..housing;
ALTER TABLE Nashville_Housing..housing
ADD SaleDateNew DATE;
UPDATE Nashville_Housing..housing
  SET 
      SaleDateNew = CONVERT(DATE, SaleDate);
GO

-- Populate Property Address Data
-- The property address is black for some rows. Need to populate the address in those rows. 
-- The Parcel ID is repeated in the table. The address of the property is linked to the Parcel ID i.e for a single Parcel ID the address will be the same.
-- The Unique ID, however, is unique to each row. Use Unique ID to distinguish between the rows and populate the address based by copying from another row with the same Parcel ID.

SELECT *
FROM Nashville_Housing..housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;
SELECT a.ParcelID, 
       a.PropertyAddress, 
       b.ParcelID, 
       b.PropertyAddress, 
       ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing..housing a
     JOIN Nashville_Housing..housing b ON a.ParcelID = b.ParcelID
                                          AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update the table with the above solution

UPDATE a
  SET 
      PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing..housing a
     JOIN Nashville_Housing..housing b ON a.ParcelID = b.ParcelID
                                          AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;
GO

-- Break down the Property Address into Address, City & State etc.
-- The property address elements are separated by a comma(,). Split the address into Address and City for a better usability.

SELECT PropertyAddress
FROM Nashville_Housing..housing;
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS PropertyAddressNew, 
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertyCity
FROM Nashville_Housing..housing;
ALTER TABLE Nashville_Housing..housing
ADD PropertyAddressNew NVARCHAR(255);
UPDATE Nashville_Housing..housing
  SET 
      PropertyAddressNew = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);
ALTER TABLE Nashville_Housing..housing
ADD PropertyCity NVARCHAR(255);
UPDATE Nashville_Housing..housing
  SET 
      PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));
GO

-- Break down the Owner Address into Address, City & State etc.
-- The owner address elements are separated by a comma(,). Split the address into Address, City and Stete for a better usability.

SELECT PARSENAME(replace(OwnerAddress, ',', '.'), 3), 
       PARSENAME(replace(OwnerAddress, ',', '.'), 2), 
       PARSENAME(replace(OwnerAddress, ',', '.'), 1)
FROM Nashville_Housing..housing;

-- Apply the above solution to the table

ALTER TABLE Nashville_Housing..housing
ADD OwnerAddressNew NVARCHAR(255);
UPDATE Nashville_Housing..housing
  SET 
      OwnerAddressNew = PARSENAME(replace(OwnerAddress, ',', '.'), 3);
ALTER TABLE Nashville_Housing..housing
ADD OwnerCity NVARCHAR(255);
UPDATE Nashville_Housing..housing
  SET 
      OwnerCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2);
ALTER TABLE Nashville_Housing..housing
ADD OwnerState NVARCHAR(255);
UPDATE Nashville_Housing..housing
  SET 
      OwnerState = PARSENAME(replace(OwnerAddress, ',', '.'), 1);
GO
SELECT *
FROM Nashville_Housing..housing;

-- Convert 'Y' and 'N' in SoldAsVacant column to 'Yes' and 'No'
-- The SoldAsVacant column contains 'Y' and 'N' in some rows. In order to maintain the consistency, update those to 'Yes' and 'No'.

SELECT DISTINCT
       (SoldAsVacant), 
       COUNT(SoldAsVacant)
FROM Nashville_Housing..housing
GROUP BY SoldAsVacant
ORDER BY 2;
SELECT SoldAsVacant,
       CASE
           WHEN SoldAsVacant = 'Y'
           THEN 'Yes'
           WHEN SoldAsVacant = 'N'
           THEN 'No'
           ELSE SoldAsVacant
       END
FROM Nashville_Housing..housing;

-- Update the table with above solution

UPDATE Nashville_Housing..housing
  SET 
      SoldAsVacant = CASE
                         WHEN SoldAsVacant = 'Y'
                         THEN 'Yes'
                         WHEN SoldAsVacant = 'N'
                         THEN 'No'
                         ELSE SoldAsVacant
                     END;
GO

-- Remove Duplicate Rows
-- Create a CTE to check and delete the number of duplicates

WITH RowNumCTE
     AS (SELECT *, 
                ROW_NUMBER() OVER(PARTITION BY ParcelID, 
                                               PropertyAddress, 
                                               SaleDate, 
                                               SalePrice, 
                                               LegalReference
         ORDER BY UniqueID) row_num
         FROM Nashville_Housing..housing)

     DELETE

     /* Replace "SELECT *" with "DELETE" to delete the duplicate rows and vice versa to view the duplicate rows */

     FROM RowNumCTE
     WHERE row_num > 1;
GO


-- Remove unused columns
-- Drop the PropertyAddress, SaleDate, OwnerAddress columns as new version of those columns have been created and these are excess to the requirement.

ALTER TABLE Nashville_Housing..housing 
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress;
GO

-- View the clean data

SELECT *
FROM Nashville_Housing..housing;
