/*

This is part 1 of my SQL project - Analyze global suicide rate data with a focus on South Korean youth. 
This part focuses on data cleaning and creating a temp table, which would be convenient for later analysis.

*/


Select *
From SuicideRateProject..NewGlobalSuicideRate


-- 1. Excluding countries with <= 3 years of data
Select count(distinct country)
From SuicideRateProject..NewGlobalSuicideRate
Where country IN (Select country From SuicideRateProject..NewGlobalSuicideRate Group by country Having Count(Distinct year)<3)


-- 2. Remove 2020 data (few countries had any)
-- in which year does the suicides_no column has the most NULL value 
Select Top 1 year, Count(*) as null_count
From SuicideRateProject..NewGlobalSuicideRate
Where suicides_no is NULL
Group by year
Order by 2


-- 3. Remove HDI column as 2/3 missing data



-- 4. Change name of column: suicides/100k pop, gdp_for_year($), gdp_per_capita($) to suicides_per_100k_pop, gdp_for_year, gdp_per_capita



-- 5. Remove the years part in the age column
Update SuicideRateProject..NewGlobalSuicideRate
Set age = REPLACE(age, ' years', '')



-- 6. Change datatype of gdp_for_year to BIGINT

-- Replace the comma
Update SuicideRateProject..NewGlobalSuicideRate
Set gdp_for_year= replace(gdp_for_year, ',', '')

-- Check for non-numeric values 
SELECT gdp_for_year
FROM SuicideRateProject..NewGlobalSuicideRate
WHERE ISNUMERIC(gdp_for_year) = 0;

-- Replace empty strings with Nulls and trim any space
Update SuicideRateProject..NewGlobalSuicideRate
SET gdp_for_year=null
Where trim(gdp_for_year) = '';

Update SuicideRateProject..NewGlobalSuicideRate
Set gdp_for_year=trim(gdp_for_year);


-- Convert to bigint
-- Convert scientific notation to FLOAT first
UPDATE SuicideRateProject..NewGlobalSuicideRate
SET gdp_for_year = CAST(CAST(gdp_for_year AS FLOAT) AS BIGINT);




-- 7. CREATE A NEW TABLE FROM THE RAW DATA THAT SATISFIES ALL THE DATA CLEANING REQUIREMENT

CREATE TABLE Temp_NewGlobalSuicideRate (
country nvarchar(255), continent nvarchar(255), year float, sex nvarchar(255), age nvarchar(255), 
suicides_no float null, population float null, suicides_per_100k_pop float null, 
gdp_for_year float null, gdo_per_capita float null, generation nvarchar(255) null
)

INSERT INTO Temp_NewGlobalSuicideRate
Select 
	country, continent, year, sex, age, suicides_no, population, 
	suicides_per_100k_pop, gdp_for_year, gdp_per_capita, generation
From SuicideRateProject..NewGlobalSuicideRate
Where year <> 2020 and 
	  country IN (Select country From SuicideRateProject..NewGlobalSuicideRate Group by country Having Count(Distinct year)>3)


-- 7.1 Delete all data after year 2015 from Temp_NewGlobalSuicideRate
-- The population data for these years was incorrect

Delete from Temp_NewGlobalSuicideRate
Where year = 2019

Delete From Temp_NewGlobalSuicideRate
Where year IN ('2016', '2017', '2018')

Select distinct year
from Temp_NewGlobalSuicideRate
order by year

-- 7.2. Adding 1 more column that calculates suicides per 100k per year for each country
Alter Table Temp_NewGlobalSuicideRate
Add suicides_per_100k_per_year int

WITH yearlysuiciderate AS (
Select 
year, sum(suicides_no)*100000/sum(population) suicides_per_100k_per_year 
From Temp_NewGlobalSuicideRate
Group by year
)
Select *
From yearlysuiciderate
Order by year

Update Temp_NewGlobalSuicideRate t
SET t.suicides_per_100k_per_year = ysr.suicides_per_100k_per_year
From Temp_NewGlobalSuicideRate t
Inner Join yearlysuiciderate ysr ON t.year = ysr.year


-- FROM NOW ON, USE TABLE Temp_NewGlobalSuicideRate TO DO ANALYSIS




	
	






















