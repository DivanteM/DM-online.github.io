/*
Covid Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT * 
FROM CovidDeaths
ORDER BY location, date

SELECT *
FROM CovidVaccinations
ORDER BY location, date

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY location, date

-- Looking at Total Cases Vs Total Deaths

SELECT * 
FROM CovidDeaths

SELECT location, date, total_cases, total_deaths
FROM CovidDeaths
ORDER BY location, date

SELECT total_cases, total_deaths, (total_deaths/total_cases)
FROM CovidDeaths

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY location, date

-- Looking at Total Cases vs Population to see what percenatge of the population were affected by Covid

Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as CovidInfected
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY location, date


-- Looking at countries with Highest Infection Rate compared to Population.

Select Location, population, MAX(cast(total_cases as int)) AS HighestInfectionCount, (CONVERT(float, (MAX(cast(total_cases as int)))) / NULLIF(CONVERT(float, population), 0))*100 as 
PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Showing the Countries with the Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCountPerCountry 
FROM CovidDeaths
WHERE continent <> ' '
GROUP BY location
ORDER BY TotalDeathCountPerCountry DESC
-- The dataset did not include NULL values and were blank instead. 


Select location, MAX(cast(total_deaths as int)) AS TotalDeathCountPerContinent 
FROM CovidDeaths
WHERE continent = ' '
GROUP BY location
ORDER BY TotalDeathCountPerContinent DESC


-- Showing continents with the highest death count per population.

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCountF 
FROM CovidDeaths
WHERE continent <> ' '
GROUP BY continent
ORDER BY TotalDeathCountF DESC
-- these aren't the correct numbers as it takes the total death count for the countries and stores it for the continent. 
-- e.g the total death count for north america is actually the total death count for the united states.
-- however, we will go ahead with this for now.


-- GLOBAL NUMBERS

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), (CONVERT(float, SUM(cast(new_deaths as int))) / NULLIF(CONVERT(float, SUM(cast(new_cases), 0)))*100 
FROM CovidDeaths
WHERE continent <> ' ' 
ORDER BY date, total_cases


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ' '
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ' ' 
ORDER BY 2,3
  -- Rolling Total to show how many covid vaccinations are recorded per day.



-- USE CTE
-- Using a CTE to perform a calculation on the partition by in previous query to see how many people were vaccinated in each country.

WITH PopvsVac (continent, Location, Date, Population, New_vaccinaions, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ' ' 
--ORDER BY 2,3	
)
SELECT *, (CONVERT(float, RollingPeopleVaccinated) / NULLIF(CONVERT(float, population), 0))*100 as PercentageOfPopVaccinated
FROM PopvsVac
-- This is the same as the query before, just in a CTE format which will allow us to perform further calculations which we couldn't do before.
-- We add this to the new select function at the end of the CTE.
-- Now we can find the percentage of the population that is vaccainated per country.
-- Here we see 12% of Albania is vaccinated.


-- TEMP TABLE
-- Using a Temp Table to perform a calculation on the  partition by in previous query to see how many people were vaccinated in each country.
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population varchar(50), 
New_vaccinations varchar(50),
RollingPeopleVaccinated varchar(50)
)



INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ' ' 

SELECT *, (CONVERT(float, RollingPeopleVaccinated) / NULLIF(CONVERT(float, population), 0))*100 as PercentageOfPopVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store for later Visualisations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> ' ' 

