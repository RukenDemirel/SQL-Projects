-- EXPLORATORY DATA ANALYSIS (EDA) --

-- DATA OVERVIEW --

-- Retrieving all records to understand the structure and content of the dataset
SELECT * 
FROM layoffs_schema.layoffs;


-- BASIC STATISTICS --

-- Finding the maximum number of employees laid off in a single instance
SELECT MAX(total_laid_off) AS max_laid_off
FROM layoffs_schema.layoffs;

-- Checking the range of layoff percentages to understand the severity
SELECT MAX(percentage_laid_off) AS max_percentage,  MIN(percentage_laid_off) AS min_percentage
FROM layoffs_schema.layoffs
WHERE percentage_laid_off IS NOT NULL;

-- Identifying companies where 100% of employees were laid off
SELECT *
FROM layoffs_schema.layoffs
WHERE percentage_laid_off = 1;

-- Analyzing funding levels of companies that laid off their entire workforce
SELECT *
FROM layoffs_schema.layoffs
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- LAYOFF ANALYSIS BY COMPANY, LOCATION, AND INDUSTRY --

-- Identifying the companies with the largest single layoff events
SELECT company, total_laid_off
FROM layoffs_schema.layoffs
ORDER BY total_laid_off DESC
LIMIT 5;

-- Identifying the companies with the highest total layoffs
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_schema.layoffs
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Summarizing layoffs by location
SELECT location, SUM(total_laid_off) AS total_layoffs
FROM layoffs_schema.layoffs
GROUP BY location
ORDER BY total_layoffs DESC
LIMIT 10;

-- Summarizing layoffs by country
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_schema.layoffs
GROUP BY country
ORDER BY total_layoffs DESC;

-- Summarizing layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_schema.layoffs
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Summarizing layoffs by company growth stage
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_schema.layoffs
GROUP BY stage
ORDER BY total_layoffs DESC;


-- LAYOFF TRENDS OVER TIME --

-- Summarizing layoffs by year
SELECT YEAR(date) AS layoff_year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_schema.layoffs
GROUP BY layoff_year
ORDER BY layoff_year ASC;

-- Identifying the top 3 companies with the highest layoffs per year
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS layoff_year, SUM(total_laid_off) AS total_layoffs
  FROM layoffs_schema.layoffs
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, layoff_year, total_layoffs, 
         DENSE_RANK() OVER (PARTITION BY layoff_year ORDER BY total_layoffs DESC) AS ranking
  FROM Company_Year
)
SELECT company, layoff_year, total_layoffs, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND layoff_year IS NOT NULL
ORDER BY layoff_year ASC, total_layoffs DESC;

-- Calculating the rolling total of layoffs per month
WITH Monthly_Layoffs AS 
(
  SELECT DATE_FORMAT(date, '%Y-%m') AS month, SUM(total_laid_off) AS total_layoffs
  FROM layoffs_schema.layoffs
  GROUP BY month
  ORDER BY month ASC
)
SELECT month, SUM(total_layoffs) OVER (ORDER BY month ASC) AS rolling_total_layoffs
FROM Monthly_Layoffs
ORDER BY month ASC;
