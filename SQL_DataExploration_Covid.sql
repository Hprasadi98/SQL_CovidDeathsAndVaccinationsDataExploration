select * from SQLDataExploration..CovidDeaths
where continent is not null
order by 3,4

--select * from SQLDataExploration..CovidVaccination
--order by 3,4

--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from SQLDataExploration..CovidDeaths
where continent is not null
order by 1, 2

--looking at total cases vs total deaths
--shows the lilelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
from SQLDataExploration..CovidDeaths
where location like '%sri%' and continent is not null
order by 1, 2

--looking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, (convert(float,total_cases)/convert(float,population))*100 as PercentPopulation
from SQLDataExploration..CovidDeaths
where location like '%sri%'
order by 1, 2

--looking at countries with highest infection rate comapared to population

select location, population, max(total_cases) as highest_infection_count, max((convert(float,total_cases)/convert(float,population)))*100 as PercentPopulationInfected
from SQLDataExploration..CovidDeaths
--where location like '%sri%'
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totlaDeathCount
from SQLDataExploration..CovidDeaths
--where location like '%sri%'
where continent is not null
group by location
order by totlaDeathCount desc

--let's break things down by continent

--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totlaDeathCount
from SQLDataExploration..CovidDeaths
--where location like '%sri%'
where continent is not null
group by continent
order by totlaDeathCount desc

--global numbers

select sum(convert(float, new_cases)) as totalCases, sum(convert(float, new_deaths)) as totalDeaths, 
CASE 
   WHEN SUM(CONVERT(FLOAT, new_cases)) = 0 THEN 0
   ELSE (SUM(CONVERT(FLOAT, new_deaths)) / SUM(CONVERT(FLOAT, new_cases))) * 100
 END as DeathPercentage
from SQLDataExploration..CovidDeaths
--where location like '%sri%'
where continent is not null
--group by date
order by 1, 2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from SQLDataExploration..CovidDeaths dea
join SQLDataExploration..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from SQLDataExploration..CovidDeaths dea
join SQLDataExploration..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (rollingPeopleVaccinated/population) as rate from PopvsVac



--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from SQLDataExploration..CovidDeaths dea
join SQLDataExploration..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (rollingPeopleVaccinated/population) as rate from #PercentPopulationVaccinated

go
--creating view to store data for later visualization

drop view if exists percentPopulationVaccinated
go
create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from SQLDataExploration..CovidDeaths dea
join SQLDataExploration..CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * from percentPopulationVaccinated

