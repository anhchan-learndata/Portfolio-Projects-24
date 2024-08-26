/* 1. Insights from dataset CovidDeathsTo24 */

/* 1.1 Daily and Cumulative Case Counts */
SELECT 
    date, 
    SUM(CAST(total_cases AS BIGINT)) AS total_cases, 
    SUM(CAST(new_cases AS BIGINT)) AS new_cases
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    location = 'World'
GROUP BY 
    date
ORDER BY 
    date DESC;

/* 1.2 Daily New Cases and Death Trends for a Specific Country */
SELECT 
    date, 
    new_cases, 
    new_deaths
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    continent IS NOT NULL 
    AND location = 'Vietnam';

/* 1.3 Total Cases vs Population */
/* Shows what percentage of population infected with COVID */
SELECT 
    location, 
    date, 
    population, 
    total_cases, 
    (total_cases/population) * 100 AS PercentPopulationInfected
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    continent IS NOT NULL
ORDER BY 
    PercentPopulationInfected DESC;

/* 1.4 Countries with the Highest Total Cases */
SELECT 
    TOP 10 location, 
    MAX(CAST(total_cases AS INT)) AS TotalCases
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    continent IS NOT NULL
GROUP BY 
    location
ORDER BY 
    TotalCases DESC;

/* 1.5 Total Cases vs Total Deaths */
/* Shows likelihood of dying if you contract Covid in your country */
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS BIGINT) / CAST(total_cases AS BIGINT)) * 100 AS DeathPercentage
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    continent IS NOT NULL
ORDER BY 
    location, date;

/* 1.6 Countries with the Highest Death Count */
SELECT 
    TOP 10 location, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount, 
    MAX(CAST(total_deaths_per_million AS FLOAT)) AS TotalDeathsPerMil
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    continent IS NOT NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;

/* 1.7 Continents with the Highest Death Count */
SELECT 
    location, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    continent IS NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;

/* 1.8 Countries with the Most ICU Patients Per Million */
SELECT 
    TOP 10 location, 
    MAX(CAST(icu_patients_per_million AS FLOAT)) AS max_icu_patients_per_million
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    continent IS NOT NULL 
GROUP BY 
    location
ORDER BY 
    max_icu_patients_per_million DESC;

/* 1.9 Daily ICU patients for the Top 5 Countries */
SELECT 
    location, 
    date, 
    icu_patients
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24
WHERE 
    location IN (
        SELECT 
            TOP 5 location 
        FROM 
            NewCovidPortfolioProject..CovidDeathsTo24
        GROUP BY 
            location
        ORDER BY 
            MAX(icu_patients) DESC
    )
    AND continent IS NOT NULL
ORDER BY 
    location, date;

/* 2. JOIN CovidVaccinationsTo24 */

/* 2.1 Global Numbers */
/* Calculate total cases, deaths, and vaccinations administered globally */
SELECT 
    SUM(CAST(dea.new_cases AS BIGINT)) AS total_cases, 
    SUM(CAST(dea.new_deaths AS BIGINT)) AS total_deaths, 
    SUM(CAST(vac.new_vaccinations AS BIGINT)) AS total_vaccinations_administered
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24 dea
JOIN 
    NewCovidPortfolioProject..CovidVaccinationsTo24 vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.location = 'World';

/* 2.2 Total Population vs Vaccination */
/* Shows Percentage of Population that has received at least one dose of Covid-19 vaccine */
SELECT 
    dea.location, 
    MAX(dea.population) AS latest_population, 
    MAX(CAST(vac.people_vaccinated AS FLOAT)) AS people_vaccinated, 
    LEAST(ROUND(MAX(CAST(vac.people_vaccinated AS FLOAT)) / MAX(dea.population) * 100, 4), 100) AS percentage_vaccinated
FROM 
    NewCovidPortfolioProject..CovidDeathsTo24 dea
JOIN 
    NewCovidPortfolioProject..CovidVaccinationsTo24 vac
ON 
    dea.location = vac.location 
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
GROUP BY 
    dea.location, dea.population
HAVING 
    MAX(vac.people_vaccinated) IS NOT NULL 
    AND MAX(dea.population) IS NOT NULL
ORDER BY 
    percentage_vaccinated DESC;

/* 2.3 Vaccination Status: One Dose, Complete Series, Booster Dose */
/* Shows percentage of population with: at least 1 dose, a complete primary series, and at least 1 booster dose of Covid-19 vaccine */
SELECT 
    vac.location, 
    LEAST(ROUND(MAX(CAST(vac.people_vaccinated AS FLOAT)) / MAX(dea.population) * 100, 4), 100) AS OneDose,
    LEAST(ROUND(MAX(CAST(vac.people_fully_vaccinated AS FLOAT)) / MAX(dea.population) * 100, 4), 100) AS CompleteSeries, 
    LEAST(ROUND(MAX(CAST(vac.total_boosters AS FLOAT)) / MAX(dea.population) * 100, 4), 100) AS Booster
FROM 
    NewCovidPortfolioProject..CovidVaccinationsTo24 vac
JOIN 
    NewCovidPortfolioProject..CovidDeathsTo24 dea
ON 
    vac.location = dea.location
WHERE 
    vac.location = 'World'
GROUP BY 
    vac.location;
