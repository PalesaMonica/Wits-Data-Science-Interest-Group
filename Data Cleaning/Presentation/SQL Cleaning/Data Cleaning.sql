
SELECT * FROM layoffs_stagging;
--Handling Duplicates
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, "date"
) AS row_num
FROM layoffs_stagging;

--Finding the duplicates
WITH duplicates_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, "date",stage,country,funds_raised_millions
) AS row_num
FROM layoffs_stagging
)
SELECT *
FROM duplicates_cte
WHERE row_num>1;

---Removing the duplicates

WITH duplicates_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, "date",stage,country,funds_raised_millions
) AS row_num
FROM layoffs_stagging
)
DELETE FROM layoffs_stagging
USING duplicates_cte
WHERE layoffs_stagging.company = duplicates_cte.company
  AND layoffs_stagging.industry = duplicates_cte.industry
  AND layoffs_stagging.total_laid_off = duplicates_cte.total_laid_off
  AND layoffs_stagging.percentage_laid_off = duplicates_cte.percentage_laid_off
  AND layoffs_stagging."date" = duplicates_cte."date"
  AND layoffs_stagging.stage= duplicates_cte.stage
  AND layoffs_stagging.country=duplicates_cte.country
  AND layoffs_stagging.funds_raised_millions=duplicates_cte.funds_raised_millions
  AND row_num > 1;


  ---Standardizing Data
  SELECT DISTINCT company
  FROM layoffs_stagging;

UPDATE layoffs_stagging
SET company = TRIM(company);

SELECT *
FROM layoffs_stagging
WHERE  industry LIKE  'Crypto%';

UPDATE layoffs_stagging
SET industry ='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country ,TRIM(TRAILING '.'  FROM country)
FROM layoffs_stagging
ORDER BY 1;

UPDATE layoffs_stagging
SET country=TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

--Convert Datatypes
SELECT TO_DATE("date", 'MM/DD/YYYY')
FROM layoffs_stagging;

ALTER TABLE layoffs_stagging
ADD COLUMN layoff_date DATE;

UPDATE layoffs_stagging
SET layoff_date = TO_DATE("date", 'YYYY/MM/DD');

ALTER TABLE layoffs_stagging
DROP COLUMN "date";

ALTER TABLE layoffs_stagging
RENAME COLUMN layoff_date TO date;

--Handling Missing Values
SELECT *
FROM layoffs_stagging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_stagging
WHERE industry IS NULL ;


UPDATE layoffs_stagging
SET industry=NULL
WHERE industry='';

SELECT t1.industry ,t2.industry
FROM layoffs_stagging t1
JOIN layoffs_stagging t2
 ON t1.company=t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE layoffs_stagging t1
SET industry = t2.industry
FROM layoffs_stagging t2
WHERE (t1.industry IS NULL)
  AND t2.industry IS NOT NULL
  AND t1.company = t2.company;

SELECT *
FROM layoffs_stagging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_stagging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_stagging;

