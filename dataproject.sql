-- ============================
-- DATA CLEANING PROJECT (MySQL)
-- ============================


-- View raw data
SELECT *
FROM layoffs;


-- ----------------------------
-- 1. CREATE STAGING TABLE
-- ----------------------------
CREATE TABLE layoffs_staging LIKE layoffs;

-- Copy data into staging table
INSERT layoffs_staging
SELECT *
FROM layoffs;


-- View staging table
SELECT *
FROM layoffs_staging;


-- ---------------------------------------------
-- 2. IDENTIFY DUPLICATES USING ROW_NUMBER()
-- ---------------------------------------------
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
) AS row_num
FROM layoffs_staging;


-- ---------------------------------------------------------
-- 3. REMOVE DUPLICATES USING CTE + ROW_NUMBER()
-- ---------------------------------------------------------
WITH duplicate_cte AS
(
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off,
        percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- Check example company
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


-- Run duplicate removal again (safety)
WITH duplicate_cte AS
(
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off,
        percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;



-- ---------------------------------------------------------
-- 4. CREATE SECOND STAGING TABLE WITH row_num FIELD
-- ---------------------------------------------------------
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
);

-- Insert + calculate duplicates
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off,
    percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;


-- Delete duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;


-- =============================
-- STANDARDIZING DATA
-- =============================

-- Trim company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Fix industry inconsistency
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean country formatting
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Convert date to DATE datatype
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- ----------------------------
-- HANDLE NULLS & BLANKS
-- ----------------------------

-- Convert empty industry → NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill missing industries using matching company/location
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


-- Delete rows where both layoffs fields are missing
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Remove row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- Final cleaned dataset
SELECT *
FROM layoffs_staging2;
