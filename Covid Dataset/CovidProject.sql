SELECT *
FROM dbo.CovidVaccinations 
ORDER BY 3,4

SELECT *
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select using data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Investigate  Total Cases, Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'
	  AND continent IS NOT NULL
ORDER BY 1,2

-- Investigate  Total Cases, Population
-- Shows percentage of population got COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS ContractRate
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'
	  AND continent IS NOT NULL
ORDER BY 1,2

-- Investigate  Total Cases, Population
-- Shows percentage of population got COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'
	  AND continent IS NOT NULL
ORDER BY 1,2

-- Investigate countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC

-- Showing countries with the highest death count per population
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Break down by continent
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBER
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2

-- Looking at Total population vs Vaccinations **
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
        , SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
   FROM dbo.CovidDeaths AS dea
   JOIN dbo.CovidVaccinations AS vac 
		ON dea.location = vac.location
		AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL
   ORDER BY 2,3

-- Temp table
   CREATE TABLE #PercentPopulationVaccinated
   (
   Continent nvarchar(255),
   Location nvarchar(255),
   Date datetime, 
   Population numeric, 
   New_vaccinations numeric, 
   RollingPeopleVaccinated numeric
   )

   INSERT INTO #PercentPopulationVaccinated
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
        , SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
   FROM dbo.CovidDeaths AS dea
   JOIN dbo.CovidVaccinations AS vac 
		ON dea.location = vac.location
		AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL
   ORDER BY 2,3

   SELECT *, (RollingPeopleVaccinated/Population)*100
   FROM #PercentPopulationVaccinated













