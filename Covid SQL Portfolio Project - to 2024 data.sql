


--1. Insights from dataset CovidDeathsto24


-- Daily and Cummulative Case Counts
Select date, sum(cast(total_cases as bigint)) total_cases, sum(cast(new_cases as bigint)) new_cases
From NewCovidPortfolioProject..CovidDeathsTo24
Where location = 'World'
Group by date
Order by date DESC


-- Daily New Cases and Death Trends for a Specific Country
Select date, new_cases, new_deaths
From NewCovidPortfolioProject..CovidDeathsTo24
Where continent is not NULL 
and location = 'Vietnam'



-- Total Cases vs Population
-- Shows what percentage of population infected with COVID
Select location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
From NewCovidPortfolioProject..CovidDeathsTo24
Where continent is not NULL
Order by 5 DESC



-- Countries with the Highest Total Cases
Select TOP 10 location, max(cast(total_cases as int)) TotalCases
From NewCovidPortfolioProject..CovidDeathsTo24
Where continent is not NULL
Group by location
Order by TotalCases DESC


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, (cast(total_deaths as bigint))/(cast(total_cases as bigint))*100 DeathPercentage
From NewCovidPortfolioProject..CovidDeathsTo24
Where --location = 'United States' 
continent is not NULL
order by 1,2



-- Countries with the Highest Death Count
Select TOP 10 location, max(cast(total_deaths as int)) TotalDeathCount, max(cast(total_deaths_per_million as float)) TotalDeathsPerMil
From NewCovidPortfolioProject..CovidDeathsTo24
Where continent is not NULL
Group by location
Order by TotalDeathCount DESC



-- Continents with the Highest Death Count
Select location, max(cast(total_deaths as int)) TotalDeathCount
From NewCovidPortfolioProject..CovidDeathsTo24
Where continent is NULL
Group by location
Order by TotalDeathCount DESC


-- Countries with the Most ICU Patients Per Million
Select Top 10 location, max(cast(icu_patients_per_million as float)) max_icu_patients_per_million
From NewCovidPortfolioProject..CovidDeathsTo24
Where continent is not NULL 
Group by location
Order by 2 DESC


-- Daily ICU patients for the Top 5 Countries
Select location, date, icu_patients
From NewCovidPortfolioProject..CovidDeathsTo24
Where location in (Select Top 5 location 
				   From NewCovidPortfolioProject..CovidDeathsTo24
				   Group by location
				   Order by max(icu_patients) DESC)
				   and continent is not NULL
Order by location, date



--2. JOIN CovidVaccinations24

-- GLOBAL NUMBERS
Select sum(cast (dea.new_cases as bigint)) total_cases, sum(cast (dea.new_deaths as bigint)) total_deaths, sum(cast(vac.new_vaccinations as bigint)) total_vaccinations_administered
From NewCovidPortfolioProject..CovidDeathsTo24 dea
Join NewCovidPortfolioProject..CovidVaccinationsTo24 vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.location = 'World'



-- Total Population vs Vaccination
-- Shows Percentage of Population that has received at least one dose of Covid-19 vaccine
Select 
	dea.location, max(dea.population) latest_population, max(cast(vac.people_vaccinated as float)) people_vaccinated, 
	least(round(max(cast(vac.people_vaccinated as float))/max(dea.population)*100,4),100) percentage_vaccinated
From NewCovidPortfolioProject..CovidDeathsTo24 dea
Join NewCovidPortfolioProject..CovidVaccinationsTo24 vac
On dea.location=vac.location and dea.date=vac.date
Where dea.continent is not NULL
Group by dea.location, dea.population
HAVING 
    MAX(vac.people_vaccinated) IS NOT NULL 
    AND MAX(dea.population) IS NOT NULL
Order by 4 DESC



-- Shows percentage of population with: at least 1 dose, a complete primary series, and at least 1 booster dose of Covid-19 vaccine
Select vac.location, least(round(max(cast(vac.people_vaccinated as float))/max(dea.population)*100,4),100) OneDose,
	   least(round(max(cast(vac.people_fully_vaccinated as float))/max(dea.population)*100,4),100) CompleteSeries, 
	   least(round(max(cast(vac.total_boosters as float))/max(dea.population)*100,4),100) Booster
From NewCovidPortfolioProject..CovidVaccinationsTo24 vac
Join NewCovidPortfolioProject..CovidDeathsTo24 dea
On vac.location=dea.location
Where vac.location = 'World'
Group by vac.location





		
	   


















































