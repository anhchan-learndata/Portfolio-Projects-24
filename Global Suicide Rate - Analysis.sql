/*
  SQL Project Part 2: Analyzing Global Suicide Rate Data with a Focus on South Korean Youth
  This part focuses on extracting insights using SQL queries.
*/

/*-----------------------------------------------------------
1. GLOBAL TREND
-----------------------------------------------------------*/

/* Calculate Global Average Suicide Rate from 1985-2015 */
WITH yearly_suicides AS (
    SELECT 
        year, 
        SUM(suicides_no) AS total_suicides, 
        SUM(population) AS total_population
    FROM Temp_NewGlobalSuicideRate
    GROUP BY year
)
SELECT 
    year,
    (total_suicides * 100000.0 / total_population) AS global_suicide_rate_per_100k
FROM yearly_suicides
ORDER BY year;


/*-----------------------------------------------------------
2. SUICIDE RATES BY CONTINENT
-----------------------------------------------------------*/

/* Global Suicides (per 100k) by Continent */
WITH yearly_suicides_by_continent AS (
    SELECT 
        continent, 
        SUM(suicides_no) AS total_suicides, 
        SUM(population) AS total_population
    FROM Temp_NewGlobalSuicideRate
    GROUP BY continent
)
SELECT 
    continent,
    (total_suicides * 100000.0 / total_population) AS suicide_rate_per_100k
FROM yearly_suicides_by_continent
ORDER BY continent;

/* Note: All Russia Federation data is counted towards Asia. Data for African countries is lacking. */

/* Trends over Time by Continent */
WITH continent_trends AS (
    SELECT 
        year, 
        continent, 
        SUM(suicides_no) / SUM(population) * 100000.0 AS avg_suicide_rate
    FROM Temp_NewGlobalSuicideRate
    GROUP BY year, continent
)
SELECT 
    year,
    MAX(CASE WHEN continent = 'Africa' THEN avg_suicide_rate END) AS Africa,
    MAX(CASE WHEN continent = 'Americas' THEN avg_suicide_rate END) AS Americas,
    MAX(CASE WHEN continent = 'Oceania' THEN avg_suicide_rate END) AS Oceania,
    MAX(CASE WHEN continent = 'Asia' THEN avg_suicide_rate END) AS Asia,
    MAX(CASE WHEN continent = 'Europe' THEN avg_suicide_rate END) AS Europe
FROM continent_trends
GROUP BY year 
ORDER BY year;


/*-----------------------------------------------------------
3. SUICIDE RATES BY COUNTRY
-----------------------------------------------------------*/

/* Global Suicides per 100k by Country */
SELECT 
    country, 
    continent, 
    SUM(suicides_no) / SUM(population) * 100000.0 AS suicide_rate_per_100k
FROM Temp_NewGlobalSuicideRate
GROUP BY country, continent
ORDER BY suicide_rate_per_100k DESC;


/*-----------------------------------------------------------
4. LINEAR TRENDS BY COUNTRY
   - Analyze how suicide rates are changing over time within each country.
   - Highlight South Korea.
-----------------------------------------------------------*/

WITH regression_components AS (
    SELECT
        country, 
        COUNT(year) AS n, 
        SUM(year) AS sum_x, 
        SUM(suicides_per_100k_per_year) AS sum_y, 
        SUM(year * suicides_per_100k_per_year) AS sum_xy,
        SUM(year * year) AS sum_x_squared
    FROM Temp_NewGlobalSuicideRate
    GROUP BY country
),
linear_regression AS (
    SELECT 
        country,
        (CAST(n AS FLOAT) * sum_xy - sum_x * sum_y) / (CAST(n AS FLOAT) * sum_x_squared - sum_x * sum_x) AS slope
    FROM regression_components
)
SELECT 
    country, 
    slope,
    CASE 
        WHEN slope > 0 THEN 'Increasing'
        WHEN slope < 0 THEN 'Decreasing'
        ELSE 'No change'
    END AS trend
FROM linear_regression
ORDER BY slope DESC;


/*-----------------------------------------------------------
5. TREND OF SUICIDE RATES IN SOUTH KOREA VS. GLOBAL AVERAGE
-----------------------------------------------------------*/

WITH combined_data AS (
    SELECT 
        year, 
        suicides_per_100k_per_year AS avg_suicide_rate,
        'Global' AS country
    FROM Temp_NewGlobalSuicideRate
    UNION ALL
    SELECT 
        year, 
        suicides_per_100k_per_year AS avg_suicide_rate,
        country
    FROM Temp_NewGlobalSuicideRate
    WHERE country = 'Republic of Korea'
)
SELECT 
    year,
    AVG(CASE WHEN country = 'Global' THEN avg_suicide_rate END) AS GlobalAvgSuicideRate,
    AVG(CASE WHEN country = 'Republic of Korea' THEN avg_suicide_rate END) AS KoreaAvgSuicideRate
FROM combined_data
GROUP BY year
ORDER BY year;


/*-----------------------------------------------------------
6. AGE AND GENDER BREAKDOWN OF SUICIDE RATES IN SOUTH KOREA
-----------------------------------------------------------*/

/* 6.1. By Age */

/* South Korea Suicides per 100K, by Age Group */
WITH south_korea_age AS (
    SELECT 
        age, 
        SUM(suicides_no) / SUM(population) * 100000.0 AS suicide_rate_per_100k
    FROM Temp_NewGlobalSuicideRate
    WHERE country = 'Republic of Korea'
    GROUP BY age
)
SELECT *
FROM south_korea_age
ORDER BY suicide_rate_per_100k;


/* Trends Over Time by Age Group */
WITH south_korea_age_trends AS (
    SELECT 
        year, 
        age,
        SUM(suicides_no) / SUM(population) * 100000.0 AS suicide_rate_per_100k
    FROM Temp_NewGlobalSuicideRate
    WHERE country = 'Republic of Korea'
    GROUP BY year, age
)
SELECT 
    year,
    MAX(CASE WHEN age = '5-14' THEN suicide_rate_per_100k END) AS Age_5_14,
    MAX(CASE WHEN age = '15-24' THEN suicide_rate_per_100k END) AS Age_15_24,
    MAX(CASE WHEN age = '25-34' THEN suicide_rate_per_100k END) AS Age_25_34,
    MAX(CASE WHEN age = '35-54' THEN suicide_rate_per_100k END) AS Age_35_54,
    MAX(CASE WHEN age = '55-74' THEN suicide_rate_per_100k END) AS Age_55_74,
    MAX(CASE WHEN age = '75+' THEN suicide_rate_per_100k END) AS Age_75_plus
FROM south_korea_age_trends
GROUP BY year 
ORDER BY year;


/* 6.2. By Gender */

/* South Korea Suicides per 100K, by Gender */
WITH south_korea_gender AS (
    SELECT 
        sex, 
        SUM(suicides_no) / SUM(population) * 100000.0 AS suicide_rate_per_100k
    FROM Temp_NewGlobalSuicideRate
    WHERE country = 'Republic of Korea'
    GROUP BY sex
)
SELECT *
FROM south_korea_gender
ORDER BY suicide_rate_per_100k;

/* Trends Over Time by Gender */
WITH south_korea_gender_trends AS (
    SELECT 
        year, 
        sex,
        SUM(suicides_no) / SUM(population) * 100000.0 AS suicide_rate_per_100k
    FROM Temp_NewGlobalSuicideRate
    WHERE country = 'Republic of Korea'
    GROUP BY year, sex
)
SELECT 
    year,
    MAX(CASE WHEN sex = 'female' THEN suicide_rate_per_100k END) AS Female,
    MAX(CASE WHEN sex = 'male' THEN suicide_rate_per_100k END) AS Male
FROM south_korea_gender_trends
GROUP BY year 
ORDER BY year;


/* 6.3. Age 15-34 Suicide Trend: South Korea vs. Global */

/* South Korea and Global Suicide Rates for Age Group 15-34 */
WITH south_korea_youth_trend AS (
    SELECT 
        year, 
        SUM(CASE WHEN age IN ('15-24', '25-34') THEN suicides_no ELSE 0 END) / 
        SUM(CASE WHEN age IN ('15-24', '25-34') THEN population ELSE 0 END) * 100000.0 AS SouthKorea_Age_15_34
    FROM Temp_NewGlobalSuicideRate
    WHERE country = 'Republic of Korea'
    GROUP BY year
),
global_youth_trend AS (
    SELECT 
        year, 
        SUM(CASE WHEN age IN ('15-24', '25-34') THEN suicides_no ELSE 0 END) / 
        SUM(CASE WHEN age IN ('15-24', '25-34') THEN population ELSE 0 END) * 100000.0 AS Global_Age_15_34
    FROM Temp_NewGlobalSuicideRate
    GROUP BY year
)
SELECT 
    sk.year, 
    sk.SouthKorea_Age_15_34, 
    g.Global_Age_15_34
FROM south_korea_y
