--select * from dbo.CovidDeaths
--Where continent is not null 
--order by 3, 4

--select * from dbo.CovidVaccination
--order by 3, 4

--Data used

select location, date, total_cases, new_cases, total_deaths, population
from portofolioprojet1..coviddeaths
Where continent is not null 
order by 1, 2

--Total cases vs total deaths
--Percentage of chance to die if you contract covid in France

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portofolioprojet1..coviddeaths
where location like '%france%'
and continent is not null 
order by 1, 2

--Total cases vs population
--Percentage of population infected with Covid

select location, date, total_cases, population, (total_deaths/population)*100 as PercentPopulationInfected
from portofolioprojet1..coviddeaths
where location like '%france%'
and continent is not null 
order by 1, 2

-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as PercentPopulationInfected
from portofolioprojet1..coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portofolioprojet1..CovidDeaths
--Where location like '%france%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT

-- Contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portofolioprojet1..CovidDeaths
--Where location like '%france%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portofolioprojet1..CovidDeaths
where continent is not null 
--group by date 
order by 1,2

-- Total Population vs Vaccinations
-- Percentage of Population that has received at least one Covid Vaccine


Select dea.continent, dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from portofolioprojet1..CovidDeaths dea
Join portofolioprojet1..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2, 3

--CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM portofolioprojet1..CovidDeaths dea
    JOIN portofolioprojet1..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PopvsVac;

-- Temp Table to perform Calculation on Partition By in previous query

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM portofolioprojet1..CovidDeaths dea
JOIN portofolioprojet1..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated;

-- View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM portofolioprojet1..CovidDeaths dea
JOIN portofolioprojet1..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 






