Select *
From Temp_NewGlobalSuicideRate

-- 1. GLOBAL TREND
-- Global average suicide rate from 1985-2015 
WITH yearly_suicides AS (
    SELECT 
        year, SUM(suicides_no) AS total_suicides, SUM(population) AS total_population
    FROM Temp_NewGlobalSuicideRate
    GROUP BY year
)
SELECT 
    year,
    (total_suicides * 100000.0 / total_population) AS global_suicide_rate_per_100k
FROM yearly_suicides
ORDER BY year;



-- 2.SUICIDE RATES BY CONTINENT
-- Global Suicides (per 100k) by Continent
WITH yearly_suicides AS (
    SELECT 
        continent, SUM(suicides_no) AS total_suicides, SUM(population) AS total_population
    FROM Temp_NewGlobalSuicideRate
    GROUP BY continent)
SELECT 
    continent,
    (total_suicides * 100000.0 / total_population) AS SuicidePer100k
FROM yearly_suicides
ORDER BY continent;

-- NOTE: All Russia Federation data is counted towards Asia. Data for African countries is lacking. 


-- Trends over time, by continent
With temp3 as (
Select year, continent, SUM(suicides_no)/SUM(population)*100000.0 GlobalAvgSuicideRates
From Temp_NewGlobalSuicideRate
Group by year,continent)
Select 
	year,
	Max(Case When continent = 'Africa' Then GlobalAvgSuicideRates End) As Africa,
	Max(Case When continent = 'Americas' Then GlobalAvgSuicideRates End) As Americas,
	Max(Case When continent = 'Oceania' Then GlobalAvgSuicideRates End) As Oceania,
	Max(Case When continent = 'Asia' Then GlobalAvgSuicideRates End) As Asia,
	Max(Case When continent = 'Europe' Then GlobalAvgSuicideRates End) As Europe
From temp3
Group by year Order by year 



--3. SUICIDE RATES BY COUNTRY 
-- Global Suicides per 100k, by Country
Select country, continent, SUM(suicides_no)/SUM(population)*100000.0 SuicidersPer100k
From Temp_NewGlobalSuicideRate
Group by country, continent
Order by 3 DESC


-- 4. LINEAR TRENDS BY COUNTRY - how the suicide rate is changing over time within each country. Highlight South Korea
With regression_components As (
	Select
		country, 
		Count(year) as n, Sum(year) as sum_x, 
		Sum(suicides_per_100k_per_year) as sum_y, 
		Sum(year*suicides_per_100k_per_year) as sum_xy,
		Sum(year*year) as sum_x_squared
	From Temp_NewGlobalSuicideRate
	Group by country
),
linear_regression AS (
	Select 
		country,
		(CAST(n AS FLOAT) * sum_xy - sum_x * sum_y) / (CAST(n AS FLOAT) * sum_x_squared - sum_x * sum_x) AS slope
	From regression_components
	)
Select 
	country, slope,
	CASE 
		WHEN slope > 0 Then 'Increasing'
		WHEN slope < 0 Then 'Decreasing'
		Else 'No change'
	End As trend
From linear_regression
Order by slope DESC



--5. TREND OF SUICIDE RATES IN SOUTH KOREA VS. GLOBAL AVERAGE
Select 
	year,
    AVG(CASE WHEN country = 'Global' THEN GlobalAvgSuicideRates END) AS GlobalAvgSuicideRates,
    AVG(CASE WHEN country = 'Republic of Korea' THEN GlobalAvgSuicideRates END) AS KoreaAvgSuicideRates
From
	(Select 
		year, suicides_per_100k_per_year as GlobalAvgSuicideRates,
		'Global' as country
	From Temp_NewGlobalSuicideRate
UNION ALL
Select 
	year, suicides_per_100k_per_year as GlobalAvgSuicideRates,
	country
From Temp_NewGlobalSuicideRate
Where country = 'Republic of Korea') as combined_data
Group by year
Order by year



--6. AGE AND GENDER BREAKDOWN OF SUICIDE RATES IN SOUTH KOREA


--6.1. BY AGE
--South Korea Suicides per 100K, by Age
With temp1 AS (
Select age, sum(suicides_no)/sum(population)*100000 SuicidesPer100k
From Temp_NewGlobalSuicideRate
Where country = 'Republic of Korea'
Group by age
)
Select *
From temp1
Order by 2


-- Trends over time, by age
WITH temp1 AS (
    SELECT year, age,
           SUM(suicides_no) / SUM(population) * 100000 AS SuicidesPer100k
    FROM Temp_NewGlobalSuicideRate
    WHERE country = 'Republic of Korea'
    GROUP BY year, age
)
SELECT 
    year,
    MAX(CASE WHEN age = '5-14' THEN SuicidesPer100k END) AS Age_5_14,
    MAX(CASE WHEN age = '15-24' THEN SuicidesPer100k END) AS Age_15_24,
	MAX(CASE WHEN age = '25-34' THEN SuicidesPer100k END) AS Age_25_34,
	MAX(CASE WHEN age = '35-54' THEN SuicidesPer100k END) AS Age_35_54,
	MAX(CASE WHEN age = '55-74' THEN SuicidesPer100k END) AS Age_55_74,
	MAX(CASE WHEN age = '75+' THEN SuicidesPer100k END) AS Age_75_Plus
FROM temp1
GROUP BY year ORDER BY year;




-- 6.2. BY SEX 
--South Korea Suicides per 100K, by Sex
With temp1 AS (
Select sex, sum(suicides_no)/sum(population)*100000 SuicidesPer100k
From Temp_NewGlobalSuicideRate
Where country = 'Republic of Korea'
Group by sex
)
Select *
From temp1
Order by 2


--Trends over time, by sex
WITH temp1 AS (
    SELECT year, sex,
           SUM(suicides_no) / SUM(population) * 100000 AS SuicidesPer100kSex
    FROM Temp_NewGlobalSuicideRate
    WHERE country = 'Republic of Korea'
    GROUP BY year, sex
)
SELECT 
    year,
    MAX(CASE WHEN sex = 'female' THEN SuicidesPer100kSex END) AS Female,
    MAX(CASE WHEN sex = 'male' THEN SuicidesPer100kSex END) AS Male
FROM temp1
GROUP BY year ORDER BY year;



--6.3.	AGE 15-34 SUICIDE TREND SOUTH KOREA VS GLOBAL AND EAST ASIAN COUNTRIES (Suicided Per 100k)
With 
temp1 AS (
	Select year, 
		SUM(CASE WHEN age = '15-24' THEN suicides_no Else 0 END + CASE WHEN age = '25-34' THEN suicides_no Else 0 END)/
		SUM(CASE WHEN age = '15-24' THEN population Else 0 END + CASE WHEN age = '25-34' THEN population Else 0 END) *100000 
		as SouthKorea_Age_15_34 -- South Korea suicide rate per 100k for age group 15-34
	From Temp_NewGlobalSuicideRate
	Where country = 'Republic of Korea'
	Group by year),
temp2 AS (
	Select year, 
		SUM(CASE WHEN age = '15-24' THEN suicides_no Else 0 END + CASE WHEN age = '25-34' THEN suicides_no Else 0 END)/
		SUM(CASE WHEN age = '15-24' THEN population Else 0 END + CASE WHEN age = '25-34' THEN population Else 0 END) *100000 
		as Global_Age_15_34 -- Global suicide rate per 100k for age group 15-34
	From Temp_NewGlobalSuicideRate
	Group by year)
Select temp1.year, temp1.SouthKorea_Age_15_34, temp2.Global_Age_15_34
From temp1
Join temp2 ON temp1.year = temp2.year
Order by temp1.year 


--6.4. AGE 15-34 SUICIDE TREND SOUTH KOREA VS GLOBAL - BY SEX
With 
temp1 AS (
	Select sex, 
		SUM(CASE WHEN age = '15-24' THEN suicides_no Else 0 END + CASE WHEN age = '25-34' THEN suicides_no Else 0 END)/
		SUM(CASE WHEN age = '15-24' THEN population Else 0 END + CASE WHEN age = '25-34' THEN population Else 0 END) *100000 
		as SouthKorea_Age_15_34 -- South Korea suicide rate per 100k for age group 15-34
	From Temp_NewGlobalSuicideRate
	Where country = 'Republic of Korea'
	Group by sex),
temp2 AS (
	Select sex, 
		SUM(CASE WHEN age = '15-24' THEN suicides_no Else 0 END + CASE WHEN age = '25-34' THEN suicides_no Else 0 END)/
		SUM(CASE WHEN age = '15-24' THEN population Else 0 END + CASE WHEN age = '25-34' THEN population Else 0 END) *100000 
		as Global_Age_15_34 -- Global suicide rate per 100k for age group 15-34
	From Temp_NewGlobalSuicideRate
	Group by sex)
Select temp1.sex, temp1.SouthKorea_Age_15_34, temp2.Global_Age_15_34
From temp1
Join temp2 ON temp1.sex = temp2.sex
Order by temp1.sex 









































