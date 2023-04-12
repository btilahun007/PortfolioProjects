

--SELECT *
--FROM Portfolio_Project.dbo.CovidDeaths
--ORDER BY 3, 4

--SELECT *
--FROM Portfolio_Project.DBO.CovidVaccinations
--ORDER BY 3, 4


--Select the data being used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project.dbo.CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
WHERE location LIKE '%states'
ORDER BY 1, 2

-- Looking at Total Cases vs Population
-- Shows waht percentage of people got Covid
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 2) AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states'
ORDER BY 1, 2

--Looking at countries with Highes Infection Rates compared to Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, 
		MAX(ROUND((total_cases/population)*100, 2)) AS PercentPopulationInfected
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Shows the countries with the Highest Death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM Portfolio_Project.dbo.CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
GROUP BY location, population
ORDER BY TotalDeathCount DESC


-- Breaking things down by continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM Portfolio_Project.dbo.CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Breaking things down by continent
--Showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM Portfolio_Project.dbo.CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
		(SUM(CAST(new_deaths AS int)) /SUM(new_cases))*100 AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths 
--WHERE location LIKE '%states'
WHERE location IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


-- Join covid deaths and vaccination tables 
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM Portfolio_Project.dbo.CovidDeaths dea
JOIN Portfolio_Project.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--Use CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM Portfolio_Project.dbo.CovidDeaths dea
JOIN Portfolio_Project.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccination numeric, 
RollingPeopleVaccinated numeric
)

Insert INTO #PercentPopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM Portfolio_Project.dbo.CovidDeaths dea
JOIN Portfolio_Project.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Create a View to store data for later visulazation

Create View PercentPopulationVaccinated AS
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
FROM Portfolio_Project.dbo.CovidDeaths dea
JOIN Portfolio_Project.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated
