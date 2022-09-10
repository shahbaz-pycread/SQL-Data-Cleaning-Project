/* 

	Cleaning Data
	
*/

-- 1. Looking all the data

SELECT *
	FROM PortfolioProject..NashvilleHousing;

-- 2. Standardize SaleDate 'Date' format

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing;

-- Creating New Column

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

/*
	Updating the newly created column and setting its value
	to the converted data value of `SaleDate` column
*/
UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


--3. Populate Property Address Data

	SELECT PropertyAddress
		FROM PortfolioProject..NashvilleHousing;

	/* 
		Checking if there is any null values in
		the PropertyAddress column.
	*/

	SELECT PropertyAddress
		FROM PortfolioProject..NashvilleHousing
		WHERE PropertyAddress is null;

	/*
		We will use self-join to populate the 
		PropertyAddress Column
	*/

	SELECT N_Housing1.ParcelID, N_Housing1.PropertyAddress, N_Housing2.ParcelID, N_Housing2.PropertyAddress, ISNULL(N_Housing1.PropertyAddress, N_Housing2.PropertyAddress)
		FROM PortfolioProject..NashvilleHousing N_Housing1
		JOIN PortfolioProject..NashvilleHousing N_Housing2
		ON N_Housing1.ParcelID = N_Housing2.ParcelID
		and N_Housing1.[UniqueID ] <> N_Housing2.[UniqueID ]
		WHERE N_Housing1.PropertyAddress is null;

	/*
		While using UPDATE with self-join,
		we should alias of table with UPDATE, not the table_name
	*/

	UPDATE N_Housing1
	SET PropertyAddress = ISNULL(N_Housing1.PropertyAddress, N_Housing2.PropertyAddress)
	FROM PortfolioProject..NashvilleHousing N_Housing1
		JOIN PortfolioProject..NashvilleHousing N_Housing2
		ON N_Housing1.ParcelID = N_Housing2.ParcelID
		and N_Housing1.[UniqueID ] <> N_Housing2.[UniqueID ]
		WHERE N_Housing1.PropertyAddress is null;


--4. Breaking out Property Address into Individual Columns(Address, City, State)

	SELECT PropertyAddress
		FROM PortfolioProject..NashvilleHousing;

	/*
		To split address into individual columns,
		we will use SUBSTRING and CHARINDEX
    */
    
    
    SELECT 
        SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) Address, -- To get all the values before ',' and not to include it(comma) , we have used -1
        SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) Address -- To get all the values after ',' and not to include it(comma), we have used +1
        FROM PortfolioProject..NashvilleHousing;


    /*
        Creating two new tables, PropertyStreetAddress and PropertyCityAddress
        to store the values that were splitted from the PropertyAddress
        columm.
    */

    ALTER TABLE NashvilleHousing
    ADD PropertyStreetAddress NVARCHAR(255);

    UPDATE NashvilleHousing
    SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

    ALTER TABLE NashvilleHousing
    ADD PropertyCityAddress NVARCHAR(255);

    UPDATE NashvilleHousing
    SET PropertyCityAddress =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--5. Breaking out OwnerAddress into individual column

    -- To split the address, we'll use PARSENAME 

    -- NOTE: PARSENAME only works with periods(.).

    -- We'll use REPLACE() to convert comma to period in OwnerAddress


    SELECT 
        PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
        PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
        PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
        FROM PortfolioProject..NashvilleHousing;

    /*
        We will create 3 new tables: OwnerStreetAddress, OwnerCityAddress, OwnerStateAddress
        to store the values that were fetched from OwnerAddress
        using PARSENAME
    */

    ALTER TABLE NashvilleHousing
    ADD OwnerStreetAddress NVARCHAR(255);

    UPDATE PortfolioProject..NashvilleHousing
    SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

    ALTER TABLE NashvilleHousing
    ADD OwnerCityAddress NVARCHAR(255);
    
    UPDATE PortfolioProject..NashvilleHousing
    SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

    ALTER TABLE NashvilleHousing
    ADD OwnerStateAddress NVARCHAR(255);

    UPDATE PortfolioProject..NashvilleHousing
    SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


--6. Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column

    -- Checking distinct and COUNT values in the SoldAsVacant columm

    SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) Total_Numbers
        FROM PortfolioProject..NashvilleHousing
        GROUP BY SoldAsVacant
        ORDER BY Total_Numbers;

    -- CASE statment
    SELECT SoldAsVacant,
        CASE 
            WHEN SoldAsVacant = 'Y' THEN 'Yes'
            WHEN SoldAsVacant = 'N' THEN 'No'
            ELSE SoldAsVacant
        END

        FROM PortfolioProject..NashvilleHousing;

    -- Updating the table

    UPDATE NashvilleHousing
    SET SoldAsVacant = CASE 
                            WHEN SoldAsVacant = 'Y' THEN 'Yes'
                            WHEN SoldAsVacant = 'N' THEN 'No'
                            ELSE SoldAsVacant
                        END


--7. Remove Duplicates 

        -- Use of CTE and window functions to find duplicate records.


        WITH RowNumCTE AS (
            SELECT *,
            ROW_NUMBER() OVER (PARTITION BY 
                                    ParcelID,
                                    PropertyAddress,
                                    SalePrice,
                                    SaleDate,
                                    LegalReference
                                    ORDER BY UniqueID
                              ) row_num
            FROM PortfolioProject..NashvilleHousing
        )

        SELECT *
            FROM RowNumCTE
            WHERE row_num > 1
            ORDER BY PropertyAddress;

        -- Deleting duplicate records from table

        DELETE    
            FROM RowNumCTE
            WHERE row_num > 1;

--8. Delete Unused Columns

    ALTER TABLE NashvilleHousing
    DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

    ALTER TABLE NashvilleHousing
    DROP COLUMN SaleDate;
            



  

    
    
		










	