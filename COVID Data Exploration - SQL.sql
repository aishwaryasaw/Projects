# Data Exploration using SQL

-- Basic SQL commands SELECT, FROM, WHERE, ORDER BY

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
where continent is not NULL
order by location, date

------------------------------------------------------------------------------------------------------------------------

-- Query to determine the likelihood of deing if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like 'Australia'
order by location, date

------------------------------------------------------------------------------------------------------------------------

-- Query to shows what percentage of total population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from PortfolioProjects..CovidDeaths
where location like 'Australia'
order by location, date

------------------------------------------------------------------------------------------------------------------------

-- Query to look at countries with highest infection rate compared to total population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
from PortfolioProjects..CovidDeaths
where continent is not NULL
Group by location, population
order by PopulationPercentageInfected desc

------------------------------------------------------------------------------------------------------------------------

-- Query to show the countries with highest Death Count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not NULL
Group by location
order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------------------------

-- Query to show the continents with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not NULL
Group by continent
order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------------------------

-- Global Numbers
select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not NULL
group by date
order by 1, 2

select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not NULL
order by 1, 2

------------------------------------------------------------------------------------------------------------------------

-- Query to get the vaccination number as per the total population based on location
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date)
as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths death
Join PortfolioProjects..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not NULL
order by 2,3

------------------------------------------------------------------------------------------------------------------------

-- Query to get the vaccination number as per the total population based on location using Common Table Expressions (CTE)
With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date)
as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths death
Join PortfolioProjects..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not NULL
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

------------------------------------------------------------------------------------------------------------------------

-- Query to get the vaccination rate as per the total population based on location using Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date)
as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths death
Join PortfolioProjects..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

------------------------------------------------------------------------------------------------------------------------

-- Query to creating View to store data for visualizations
Create View PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date)
as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths death
Join PortfolioProjects..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not NULL
