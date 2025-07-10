'''
	SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [Portfolio Project 1].[dbo].[CovidDeaths ]

  SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM [Portfolio Project 1]. .[CovidDeaths ]
	ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihoodof dying if contacted with COVID in your country, Africa in this case scenerio


 SELECT Location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
	FROM [Portfolio Project 1]. .[CovidDeaths ]
	WHERE location like '%Africa%'
	ORDER BY 1,2

-- Looking at Total cases vs Population
-- Looking at what percentage of populatiion got COVID


SELECT Location, date,population, total_cases, new_cases, total_deaths,(total_deaths/population)*100 AS  PercentPopulationInfected 
	FROM [Portfolio Project 1]. .[CovidDeaths ]
	WHERE location like '%Africa%'
	ORDER BY 1,2

--Looking at countries with Highest infection rate compared to population	

	SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_deaths/population))*100 AS  PercentPopulationInfected 
	FROM [Portfolio Project 1]. .[CovidDeaths ]
-- WHERE location like '%Africa%'
	GROUP BY location, population
	ORDER BY PercentPopulationInfected DESC

--	Showing Countries with Highest Death Count per Population

	SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
		FROM [Portfolio Project 1]. .[CovidDeaths ]
	--WHERE Location like %Africa%
		GROUP BY location
		ORDER BY TotalDeathCount DESC

-- Break things down by continent

--Showing the continent with the highest death count per population

	SELECT Continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
		FROM [Portfolio Project 1]. .[CovidDeaths ]
	--WHERE Location like %Africa%
		WHERE continent IS NOT NULL
		GROUP BY continent
		ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
	
	SELECT Location, date,population, total_cases, new_cases, total_deaths,(total_deaths/population)*100 AS  PercentPopulationInfected 
	FROM [Portfolio Project 1]. .[CovidDeaths ]
	WHERE location like '%Africa%'
	AND continent IS NOT NULL
	ORDER BY 1,2

	SELECT  SUM(new_cases) AS TotalCases, SUM(CAST (new_deaths AS INT)) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
	FROM [Portfolio Project 1]. .[CovidDeaths ]
	--WHERE location like '%Africa%'
	WHERE continent IS NOT NULL
	--GROUP BY date
	ORDER BY 1,2

	-- Joining both tables

	SELECT *
	FROM [Portfolio Project 1]..[CovidDeaths ] dea
	JOIN [Portfolio Project 1]..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date

	-- Looking at Total Population vs Vaccinations
--USE CTE
--, (RollingPeopleVaccinated/population)*100
WITH POPVSVAC (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
	FROM [Portfolio Project 1]..[CovidDeaths ] dea
	JOIN [Portfolio Project 1]..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
	FROM POPVSVAC

DROP TABLE IF EXISTS #PERCENNTPOPULATIONVACINATED
CREATE TABLE #PERCENNTPOPULATIONVACINATED
(
	CONTINENT NVARCHAR(255),
	LOCATION NVARCHAR(255),
	DATE DATETIME,
	POPULATION NUMERIC,
	NEW_VACCINATIONS NUMERIC,
	ROLLINGPEOPLEVACCINATED NUMERIC
)


INSERT INTO #PERCENNTPOPULATIONVACINATED
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
	FROM [Portfolio Project 1]..[CovidDeaths ] dea
	JOIN [Portfolio Project 1]..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
	FROM #PERCENNTPOPULATIONVACINATED
		
CREATE VIEW PERCENNTPOPULATIONVACINATED AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
	FROM [Portfolio Project 1]..[CovidDeaths ] dea
	JOIN [Portfolio Project 1]..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		--ORDER BY 2,3
'''
