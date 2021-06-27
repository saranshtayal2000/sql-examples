SELECT *
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION LIKE '%india%'
where continent is not null
order by 1,2

-- Looking at Total Cases vs population
--- shows what %of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION LIKE '%india%'
where continent is not null
order by 1,2

--looking at highest infection rate compared to population
SELECT Location,population,date,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--where continent is not null
Group by location, population, date
order by PercentPopulationInfected desc

-- showing the countries with the highest death count per population
SELECT Location,max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- lets break things by continent
-- showing the continents with highest death count per population
SELECT continent,max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc
 

 -- GLOBAL NUMBERS

SELECT  sum(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE LOCATION LIKE '%india%'
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccinations

SELECT dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
order by 2,3

--we can't use already created column for further operations so we need either cet's or temp tables

--use CTE
With PopvsVac(Continent, Location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW T STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated

SELECT Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null
and location not in ('World' , 'European Union' , 'International')
Group by location
order by TotalDeathCount desc