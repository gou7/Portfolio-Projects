Select *
From [Goutham Portfolio]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Goutham Portfolio]..Covidvaccinations
--order by 3,4
-- Select Data that we are going to be using
Select Location, date, total_cases,new_cases, total_deaths, population
From [Goutham Portfolio]..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases VS Total Deaths 

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From [Goutham Portfolio]..CovidDeaths
--Order by 1,2

SELECT 
    Location, 
    Date, 
    Total_Cases, 
    Total_Deaths, 
    (CONVERT(float, Total_Deaths) / CONVERT(float, Total_Cases)) * 100 AS DeathPercentage
FROM 
    [Goutham Portfolio]..CovidDeaths
	where location like '%india%'
	and  continent is not null

ORDER BY 
    1, 2;
--Shows what percentage of population got covid
	SELECT 
    Location, 
    Date,
	population,
    Total_Cases, 
     
    (CONVERT(float, total_cases) / CONVERT(float, population)) * 100 AS DeathPercentage
FROM 
    [Goutham Portfolio]..CovidDeaths
	where location like '%india%'
ORDER BY 
    1, 2;

-- looking at countries with highest infection rate compared to population
SELECT 
    Location, 
    Population, 
    MAX(Total_Cases) as HighestInfectionCount,
    (MAX(CONVERT(float, Total_Cases)) / CONVERT(float, Population)) * 100 as PercentPopulationInfection
FROM 
    [Goutham Portfolio]..CovidDeaths
GROUP BY 
    Location, Population
ORDER BY PercentPopulationInfection desc

--Showing Countries with highest Death Count per population

SELECT 
    Location, MAX(cast(total_deaths as int)) as totaldeathcount
FROM 
    [Goutham Portfolio]..CovidDeaths
	Where continent is not null
GROUP BY 
    Location, Population
ORDER BY totaldeathcount desc




-- Let's break thing down by continent
-- Showing continents with highest death count per population
SELECT 
    continent, 
    MAX(cast(total_deaths as int)) as totaldeathcount
FROM 
    [Goutham Portfolio]..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    totaldeathcount DESC;




--Global Numbers
SELECT 
    date, 
    SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths AS int)) as total_deaths, 
    CASE 
        WHEN SUM(CAST(new_cases AS int)) = 0 THEN NULL
        ELSE (SUM(CAST(new_deaths AS int)) / NULLIF(SUM(CAST(new_cases AS int)), 0)) * 100 
    END as DeathPercentage
FROM 
    [Goutham Portfolio]..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    date, total_cases;


--Total
SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 
    END AS death_percentage
FROM 
    [Goutham Portfolio]..CovidDeaths
WHERE 
    continent IS NOT NULL;



-- Looking at total population vs vaccinations
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    [Goutham Portfolio]..CovidDeaths dea
JOIN 
    [Goutham Portfolio]..Covidvaccinations vac ON dea.location = vac.location
                                               AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    2, 3;




-- USE CITY
WITH PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        [Goutham Portfolio]..CovidDeaths dea
    JOIN 
        [Goutham Portfolio]..Covidvaccinations vac ON dea.location = vac.location
                                                   AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    *, 
    (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM 
    PopvsVac
ORDER BY 
    location, date;






-- TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    [Goutham Portfolio]..CovidDeaths dea
JOIN 
    [Goutham Portfolio]..Covidvaccinations vac ON dea.location = vac.location
                                               AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
--ORDER BY 
    --2, 3;
	SELECT 
    *, 
    (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
	FROM #PercentPopulationVaccinated





	--TRY
	CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    [Goutham Portfolio]..CovidDeaths dea
JOIN 
    [Goutham Portfolio]..Covidvaccinations vac ON dea.location = vac.location
                                               AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

SELECT 
    *, 
    (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM 
    #PercentPopulationVaccinated;

DROP TABLE #PercentPopulationVaccinated;


--Creating view to store data for later visulization

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    [Goutham Portfolio]..CovidDeaths dea
JOIN 
    [Goutham Portfolio]..Covidvaccinations vac ON dea.location = vac.location
                                               AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

SELECT 
    *, 
    (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM 
    #PercentPopulationVaccinated;

DROP TABLE #PercentPopulationVaccinated;
--
CREATE VIEW PercentPopulationVaccinated as 

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    [Goutham Portfolio]..CovidDeaths dea
JOIN 
    [Goutham Portfolio]..Covidvaccinations vac ON dea.location = vac.location
                                               AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL; 

	SELECT *
	FROM PercentPopulationVaccinated