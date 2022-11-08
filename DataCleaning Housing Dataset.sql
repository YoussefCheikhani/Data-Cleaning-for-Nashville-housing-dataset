Select *
from PortfolioProject..NashvilleHousing

-- Convert DATETIME to DATE

Select SaleDate, CONVERT(DATE,SaleDate)
From PortfolioProject..NashvilleHousing

-- Replace DATETIME in SaleDate with DATE type

Update PortfolioProject..NashvilleHousing
Set SaleDate = CONVERT(DATE,SaleDate)	--Doesn't work all the time?? We do ALTER instead

Alter Table NashvilleHousing
Alter Column SaleDate Date

-- Populating NULL PropertyAdresses based on ParcelID (If a null PropertyAdress has the same ParcelID as a known one we can use the same location)

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

Select PropertyAddress
From PortfolioProject..NashvilleHousing
Where ParcelID = '025 07 0 031.00'         -- Address match "410  ROSEHILL CT, GOODLETTSVILLE"

Select A.PropertyAddress, B.ParcelID, B.PropertyAddress, A.ParcelID, ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject..NashvilleHousing A, PortfolioProject..NashvilleHousing B  --Self JOIN to find all matches
Where A.PropertyAddress is null
And A.[UniqueID ]<>B.[UniqueID ]          -- or And B.PropertyAddress is not null
And A.ParcelID = B.ParcelID


Update A
Set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject..NashvilleHousing A, PortfolioProject..NashvilleHousing B 
Where A.PropertyAddress is null
And A.[UniqueID ]<>B.[UniqueID ]
And A.ParcelID = B.ParcelID


-- Breaking out Address into atomic fields (Address, City, State)

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,				--Or use PARSENAME
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing

	--Creating new column for Address & city

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertyCity nvarchar(255)

Update PortfolioProject..NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

-- Owner Address split

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1),	--State
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),	--City
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)	--Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress varchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter Table NashvilleHousing
Add OwnerCity varchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter Table NashvilleHousing
Add OwnerState varchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


--Change Y and N to Yes and No

Select DISTINCT SoldAsVacant
From PortfolioProject..NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Add SoldAsVacantUpdated varchar(255)


Update PortfolioProject..NashvilleHousing
Set SoldAsVacantUpdated = 
(CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END)

Select DISTINCT SoldAsVacantUpdated
From PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = SoldAsVacantUpdated

Select DISTINCT SoldAsVacant, Count(SoldAsVacant)	--Check
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant

Alter Table PortfolioProject..NashvilleHousing
Drop Column SoldAsVacantUpdated



--Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (									--Can also use RANK()
	PARTITION BY ParcelID,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) rownum                            --when rownum > 1 <==> duplicate row 
From PortfolioProject..NashvilleHousing
--Order by rownum DESC
)

Delete
From RowNumCTE
Where rownum>1

--Select * 
--From PortfolioProject..NashvilleHousing
--Where rownum>1


--Delete unused columns

Select * 
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict
