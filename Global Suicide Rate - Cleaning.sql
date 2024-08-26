/*
This is part 1 of my SQL project - Analyze Global Suicide Rate data with a focus on South Korean youth. 
This part focuses on data cleaning and creating a temp table, which would be convenient for later analysis.
*/

/* View the initial dataset */
SELECT *
FROM SuicideRateProject..NewGlobalSuicideRate;


/* 1. Excluding countries with <= 3 years of data */
SELECT COUNT(DISTINCT country)
FROM SuicideRateProject..NewGlobalSuicideRate
WHERE country IN (
    SELECT country
    FROM SuicideRateProject..NewGlobalSuicideRate
    GROUP BY country
    HAVING COUNT(DISTINCT year) < 3
);


/* 2. Remove 2020 data (few countries had any) */
/* Identifying the year with the most NULL values in the suicides_no column */
SELECT TOP 1 year, COUNT(*) AS null_count
FROM SuicideRateProject..NewGlobalSuicideRate
WHERE suicides_no IS NULL
GROUP BY year
ORDER BY null_count DESC;


/* 3. Remove HDI column as 2/3 of the data is missing */
/* (No SQL statement provided for removing column, consider it as a note) */


/* 4. Change name of columns: suicides/100k pop, gdp_for_year($), gdp_per_capita($) */
/* to suicides_per_100k_pop, gdp_for_year, gdp_per_capita */
/* (No SQL statement provided, consider it as a note) */


/* 5. Remove the 'years' part in the age column */
UPDATE SuicideRateProject..NewGlobalSuicideRate
SET age = REPLACE(age, ' years', '');


/* 6. Change datatype of gdp_for_year to BIGINT */

/* 6.1 Replace the comma in gdp_for_year */
UPDATE SuicideRateProject..NewGlobalSuicideRate
SET gdp_for_year = REPLACE(gdp_for_year, ',', '');

/* 6.2 Check for non-numeric values in gdp_for_year */
SELECT gdp_for_year
FROM SuicideRateProject..NewGlobalSuicideRate
WHERE ISNUMERIC(gdp_for_year) = 0;

/* 6.3 Replace empty strings with NULLs and trim any space in gdp_for_year */
UPDATE SuicideRateProject..NewGlobalSuicideRate
SET gdp_for_year = NULL
WHERE TRIM(gdp_for_year) = '';

UPDATE SuicideRateProject..NewGlobalSuicideRate
SET gdp_for_year = TRIM(gdp_for_year);

/* 6.4 Convert gdp_for_year to BIGINT */
/* Convert scientific notation to FLOAT first */
UPDATE SuicideRateProject..NewGlobalSuicideRate
SET gdp_for_year = CAST(CAST(gdp_for_year AS FLOAT) AS BIGINT);


/* 7. CREATE A NEW TABLE FROM THE RAW DATA THAT SATISFIES ALL THE DATA CLEANING REQUIREMENTS */
CREATE TABLE Temp_NewGlobalSuicideRate (
    country NVARCHAR(255),
    continent NVARCHAR(255),
    year FLOAT,
    sex NVARCHAR(255),
    age NVARCHAR(255),
    suicides_no FLOAT NULL,
    population FLOAT NULL,
    suicides_per_100k_pop FLOAT NULL,
    gdp_for_year FLOAT NULL,
    gdp_per_capita FLOAT NULL,
    generation NVARCHAR(255) NULL
);

INSERT INTO Temp_NewGlobalSuicideRate
SELECT 
    country, continent, year, sex, age, suicides_no, population, 
    suicides_per_100k_pop, gdp_for_year, gdp_per_capita, generation
FROM SuicideRateProject..NewGlobalSuicideRate
WHERE year <> 2020 
  AND country IN (
      SELECT country
      FROM SuicideRateProject..NewGlobalSuicideRate
      GROUP BY country
      HAVING COUNT(DISTINCT year) > 3
  );


/* 7.1 Delete all data after year 2015 from Temp_NewGlobalSuicideRate */
/* The population data for these years was incorrect */

DELETE FROM Temp_NewGlobalSuicideRate
WHERE year = 2019;

DELETE FROM Temp_NewGlobalSuicideRate
WHERE year IN ('2016', '2017', '2018');

/* Check remaining distinct years in Temp_NewGlobalSuicideRate */
SELECT DISTINCT year
FROM Temp_NewGlobalSuicideRate
ORDER BY year;


/* 7.2 Add a column that calculates suicides per 100k per year for each country */
ALTER TABLE Temp_NewGlobalSuicideRate
ADD suicides_per_100k_per_year INT;

WITH yearlysuiciderate AS (
    SELECT 
        year, 
        SUM(suicides_no) * 100000 / SUM(population) AS suicides_per_100k_per_year 
    FROM Temp_NewGlobalSuicideRate
    GROUP BY year
)
SELECT *
FROM yearlysuiciderate
ORDER BY year;

UPDATE Temp_NewGlobalSuicideRate t
SET t.suicides_per_100k_per_year = ysr.suicides_per_100k_per_year
FROM Temp_NewGlobalSuicideRate t
INNER JOIN yearlysuiciderate ysr ON t.year = ysr.year;


/* FROM NOW ON, USE TABLE Temp_NewGlobalSuicideRate TO DO ANALYSIS */
