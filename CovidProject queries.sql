

-- Looking at Total Cases vs Total Deaths per Country
--Shows likehood of dying if you contract covid in Portugal

SELECT location, date, total_cases, total_deaths,  CASE 
        WHEN total_cases = 0 THEN 0 -- Handle division by zero
        ELSE (total_deaths / total_cases) * 100
    END AS death_percentage
FROM dbo.CovidDeaths
WHERE location like 'Portugal'
ORDER BY 1,2




-- Total cases vs Population
--Shows what percentage of population in Portugal got covid

SELECT location, date,  population, total_cases, (total_cases / population) * 100 AS percent_population_infected
FROM dbo.CovidDeaths
WHERE location like 'Portugal'
ORDER BY total_cases




--What countries has the highest infection rate compared to population
SELECT 
    location,
    population,
    HighestInfectionCount,
    CASE 
        WHEN HighestInfectionCount = 0 OR population = 0 THEN 0
        ELSE (CONVERT(FLOAT, HighestInfectionCount) / population) * 100 
    END AS percent_population_infected
FROM (
    SELECT 
        location, 
        population, 
        MAX(total_cases) AS HighestInfectionCount
    FROM dbo.CovidDeaths
    GROUP BY location, population
) AS Subquery
WHERE location NOT IN ('World', 'North America', 'South America', 'European Union', 'Europe', 'Asia', 'Africa')
ORDER BY percent_population_infected DESC;




-- Showing the Countries with the Highest Death Count per Population
SELECT 
    location,
    MAX(CAST(total_deaths AS int)) As total_death_count
FROM dbo.CovidDeaths
WHERE location NOT IN ('World', 'North America', 'South America', 'European Union', 'Europe', 'Asia', 'Africa')
GROUP BY location
ORDER BY total_death_count DESC



--Showing continent with the highest death count
SELECT continent, SUM(CAST(new_deaths AS float)) AS total_death_count
FROM dbo.CovidDeaths
WHERE continent !=''
GROUP BY continent
ORDER BY total_death_count DESC



-- Global Numbers
SELECT SUM(new_cases) As total_cases, SUM(CAST(new_deaths as float)) AS total_deaths, 
CASE WHEN SUM(new_cases) = 0 THEN 0 
ELSE SUM(CAST(new_deaths as float))/SUM(new_cases)  * 100
END AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent !=''
ORDER BY 1,2




--Total Population vs Vaccination
WITH VaccVsPop AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinatedPeople
FROM CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vacc
ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent != '')

SELECT *, 
CASE WHEN CONVERT(float,population) = 0 THEN 0 
ELSE (RollingVaccinatedPeople/CONVERT(int,population) ) * 100
END
FROM VaccVsPop



--Temp Table
DROP TABLE IF exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
continent varchar(250),
location varchar(250), 
date Datetime,
population float,
new_vaccinations float,
RollingVaccinatedPeople float
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinatedPeople
FROM CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vacc
ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent != ''
ORDER BY 2,3

SELECT *, 
CASE WHEN CONVERT(float,population) = 0 THEN 0 
ELSE (RollingVaccinatedPeople/CONVERT(int,population) ) * 100
END
FROM #PercentPopulationVaccinated




--Create View to store data for visulalizations

-- Showing the Countries with the Highest Death Count per Population
CREATE VIEW HighestDeathCountPerCountry AS 
SELECT 
    location,
    MAX(CAST(total_deaths AS int)) As total_death_count
FROM dbo.CovidDeaths
WHERE location NOT IN ('World', 'North America', 'South America', 'European Union', 'Europe', 'Asia', 'Africa')
GROUP BY location


SELECT * 
FROM HighestDeathCountPerCountry



