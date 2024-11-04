-- DATA CLEANING --

-- Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT *
FROM layoffs_dataset;

	-- REMOVING THE DUPLICATES --

-- Adding Row Number

SELECT *, ROW_NUMBER() OVER 
	(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_dataset;

-- Creating a new table with 'row_num' column

ALTER TABLE layoffs_schema.layoffs_dataset ADD row_num INT;

SELECT *
FROM layoffs_schema.layoffs_dataset
;

CREATE TABLE `layoffs_schema`.`layoffs` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `layoffs_schema`.`layoffs`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_schema.layoffs_dataset;


-- Selecting the Duplicates

SELECT * FROM layoffs
WHERE row_num > 1;

-- Double checking if it is correct

SELECT * FROM layoffs
WHERE company LIKE 'Yahoo%';

-- Delete Duplicates

DELETE FROM layoffs
WHERE row_num >= 2;

	-- STANDARDIZE DATA & FIXING THE ERRORS --

-- Data type of 'date' column is text. Format 'date' column 

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs;

UPDATE layoffs
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs
MODIFY COLUMN `date` DATE;

-- Checking each unique value in each column 

-- 'company' column
SELECT company
FROM layoffs
ORDER BY company;

-- Cleaning the white space in the 'company' column

SELECT company, TRIM(company)
FROM layoffs;

UPDATE layoffs
SET company = TRIM(company);

-- 'country' column
SELECT DISTINCT country
FROM layoffs
ORDER BY  country;

-- Here there are United States and United States. on the country 'column'
-- Remove the '.'

UPDATE layoffs
SET country = TRIM(TRAILING '.' FROM country);

-- 'industry' column
SELECT DISTINCT industry
FROM layoffs
ORDER BY  industry;

-- There are values 'Crypto', 'Crypto Currency' and 'CryptoCurrency' in 'industry' column
-- Change them all to 'Crypto'
 
UPDATE layoffs
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- 'location' column
SELECT DISTINCT location
FROM layoffs
ORDER BY  location;
-- Nothing is wrong here


	-- HANDLING THE MISSING DATA --

-- There are blank rows on 'industry column. Convert all blank rows to NULL

SELECT company, location, industry
FROM layoffs
WHERE industry = '';

UPDATE layoffs
SET industry = NULL
WHERE industry = '';

-- Filling the empty rows if possible 

SELECT *
FROM layoffs
WHERE industry IS NULL;

-- Check all 4 rows

SELECT *
FROM layoffs
WHERE company LIKE 'Bally%';
-- Nothing is wrong here there is only one row

SELECT *
FROM layoffs
WHERE company LIKE 'Airbnb%';

-- There are 2 rows with Airbnb in 'company' column. One of the 'industry' is Travel and other NULL 
-- Set the NULL to Travel
-- Do this for all companies
-- Also checking if the locations are also the same

SELECT t1.company, t1.location, t2.location, t1.industry, t2.industry
FROM layoffs t1
JOIN layoffs t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

-- Now Update t1

UPDATE layoffs t1
JOIN layoffs t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

-- Remove 'row_num' column

ALTER TABLE layoffs
DROP COLUMN row_num;

SELECT *
FROM layoffs;

	

















