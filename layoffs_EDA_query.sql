-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging_2;

-- Highest number of layoffs and the highest layoff percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2;

-- Companies that laid off 100% of their workforce
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC;

-- Total layoffs per company across all recorded layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

-- Earliest and latest layoff dates
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_2;

-- Total layoffs aggregated by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY (`date`) -- groups the data by the entire date value, not by the year
				  -- multiple different days in the same year and each day becomes its own group.
ORDER BY 1 DESC;

-- Total layoffs per year
SELECT company, YEAR(`date`) as `year`, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`) -- groups all rows based on the year extracted from the date
							   -- All dates in the same year are combined into one group
ORDER BY company ASC;

-- Groups the company by stage by adding up total layoffs for each stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;

-- Group by company with average value of percentage_laid_off each company
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

-- Total layoffs for each company by year
SELECT company, YEAR(`date`) as `year`, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, `year` 
ORDER BY 3 DESC;  -- companies with the highest layoffs first

-- CTE to calculate total layoffs by company and year
WITH Company_Year (company, years, sum_total_laid_off) AS
(
SELECT company, YEAR(`date`) as `year`, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS -- Rank companies within each year by total layoffs
(
SELECT *, 
DENSE_RANK () OVER (PARTITION BY years ORDER BY sum_total_laid_off DESC) AS rank_over_years -- PARTITION BY assigns a rank for each company within the same year
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE rank_over_years <= 5;  -- Return only the top 5 companies per year based on layoffs

-- Select the year-month part of the date and calculate total layoffs per month
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS sum_total_laid_off -- Extracts YYYY-MM (first 7 characters) from the date
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

-- Calculate total layoffs per month using DATE_FORMAT
SELECT DATE_FORMAT(`date`, '%Y-%m') AS `month`, SUM(total_laid_off) AS sum_total_laid_off  -- Formats date as YYYY-MM
FROM layoffs_staging_2
WHERE `date` IS NOT NULL
GROUP BY `month`
ORDER BY `month` ASC;

-- Calculate total layoffs per month with month names
SELECT DATE_FORMAT(`date`, '%Y-%b') AS `month`, SUM(total_laid_off) AS sum_total_laid_off -- Formats as 2025-Jan, 2025-Feb and so on
FROM layoffs_staging_2
WHERE `date` IS NOT NULL
GROUP BY `month`
ORDER BY MIN(`date`) ASC;

-- CTE for calculating total layoffs for each month 
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS sum_total_laid_off -- Extracts YYYY-MM (first 7 characters) from the date
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, sum_total_laid_off, SUM(sum_total_laid_off) OVER (ORDER BY `month`) AS rolling_total -- Adds up the totals month by month
FROM Rolling_Total;

SELECT *
FROM layoffs_staging_2