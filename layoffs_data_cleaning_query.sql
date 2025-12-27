-- Data Cleaning Steps
	-- 1. Remove Duplicates
	-- 2. Standerdize the Data
	-- 3. Null Values or Blank Values
	-- 4. Remove any Columns or Rows

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- Create a duplicate "layoffs" table as "layoffs_staging"
CREATE TABLE layoffs_staging
LIKE layoffs;
SELECT *
FROM layoffs_staging;

-- Insert data from "layoffs" table to "layoffs_staging" 
INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- Adding a row_number column
SELECT *,
ROW_NUMBER () OVER (PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- Creating a CTE to remove duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER () OVER (PARTITION BY company, location, total_laid_off, `date`, 
                                percentage_laid_off, industry, stage, country, funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Create a new table name "layoffs_staging_2" before deleting the columns and data
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` int DEFAULT NULL,
  `country` text,
  `date_added` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging_2;

INSERT INTO layoffs_staging_2
SELECT *,
ROW_NUMBER () OVER (PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging_2
WHERE row_num > 1;

-- Delete the duplicates from layoffs_staging_2 table (Data which row_num is greater than 1)
DELETE
FROM layoffs_staging_2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging_2;

-- Drop the row_num column
ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;

-- 2. Standerdize the Data 
-- Findidng the issues and fixing them

SELECT DISTINCT company, (TRIM(company)) -- Removing  the whitespaces of company column
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = TRIM(company); -- Update the column with removed whitespaces version

SELECT *
FROM layoffs_staging_2;

-- Industry column
SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY 1;
-- Apperently all good

-- Country column
SELECT DISTINCT country
FROM layoffs_staging_2
ORDER BY 1;

SELECT country
FROM layoffs_staging_2
WHERE country LIKE 'United S%';

-- Location column
SELECT DISTINCT location
FROM layoffs_staging_2
ORDER BY 1;

SELECT *
FROM layoffs_staging_2
WHERE location LIKE 'Kuala%';

UPDATE layoffs_staging_2
SET location = 'Kuala Lumpur, Non-U.S.'
WHERE location LIKE 'Kuala%';

SELECT *
FROM layoffs_staging_2
WHERE location LIKE 'Brisbane%';

UPDATE layoffs_staging_2
SET location = 'Brisbane, Non-U.S.'
WHERE location LIKE 'Brisbane%';

SELECT *
FROM layoffs_staging_2
WHERE location LIKE 'Singapore%';

UPDATE layoffs_staging_2
SET location = 'Singapore, Non-U.S.'
WHERE location LIKE 'Singapore%';
-- Location column apperently all good

-- Change the format of Date Column
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') AS `date_formated`
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE; -- Change the text format to Date format

SELECT *
FROM layoffs_staging_2;

-- Change the format of date_added Column
SELECT date_added,
STR_TO_DATE(date_added, '%m/%d/%Y') AS date_added_formated
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y')
WHERE date_added LIKE '%/%';

ALTER TABLE layoffs_staging_2
MODIFY COLUMN date_added DATE;

SELECT *
FROM layoffs_staging_2;

-- 3. Null Values or Blank Values
-- Convert the missing/blank values into NULLs
UPDATE layoffs_staging_2
SET total_laid_off = NULL
WHERE total_laid_off = '';

UPDATE layoffs_staging_2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

-- Convert empty string values in any columns to NULL
UPDATE layoffs_staging_2
SET 
	company = NULLIF(company, ''),
    location = NULLIF(location, ''),
    total_laid_off = NULLIF(total_laid_off, ''),
    `date` = NULLIF(`date`, ''),
    percentage_laid_off = NULLIF(percentage_laid_off, ''),
    industry = NULLIF(industry, ''),
    `source` = NULLIF(`source`, ''),
    stage = NULLIF(stage, ''),
    funds_raised = NULLIF(funds_raised, ''),
    country = NULLIF(country, ''),
    `date_added` = NULLIF(`date_added`, '');
-- Now all missing values are converted to NULL

-- 4. Remove any Columns or Rows
SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging_2;


-- Data Cleaning is done!