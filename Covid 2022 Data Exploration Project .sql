select * 
from [Portfolio Projects]..['Covid deaths$']
WHERE continent is not NULL
order by 3,4

--select the data that we are using
select location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio Projects]..['Covid deaths$']
WHERE continent is not NULL
order by 1,2

--look at total cases vs total deaths 
--liklihihood of dying if have covid depending on location  
select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as deathpercentage 
from [Portfolio Projects]..['Covid deaths$']
WHERE continent is not NULL
--and location like '%states%'
order by 1,2

--look at total cases vs population 
--percentage of population that got covid
select location, date, total_cases, population, (total_cases/population)* 100 as covidpercentage 
from [Portfolio Projects]..['Covid deaths$']
WHERE continent is not NULL
--and location like '%states%'
order by 1,2

--look at countries with highest infection rate compared to population
select location, max(total_cases) as highinfection, population, (max(total_cases)/population)* 100 as covidpercentage 
from [Portfolio Projects]..['Covid deaths$']
WHERE continent is not NULL
--and location like '%states%'
group by location, population
order by covidpercentage desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as bigint)) as highdeath
from [Portfolio Projects]..['Covid deaths$']
WHERE continent is not NULL
--and location like '%states%'
group by location
order by highdeath desc

--showing continents with highest death count per population
select continent, max(cast(total_deaths as bigint)) as highdeath
from [Portfolio Projects]..['Covid deaths$']
WHERE continent is not NULL
--and location like '%states%'
group by continent
order by highdeath desc

--global
select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from [Portfolio Projects]..['Covid deaths$']
WHERE continent is not NULL
--and location like '%states%'
group by date
order by 1,2

--join covid deaths and vaccinations table together 
--looking at total population vs vaccinations 
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) OVER (partition by death.location order by death.location, death.date) as rollingpeoplevac
From [Portfolio Projects]..['Covid deaths$'] death
join [Portfolio Projects]..['Covid vac$'] vac
on death.location = vac.location 
and death.date = vac.date
WHERE death.continent is not null 
order by 2,3

--using cte
With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevac)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) OVER (partition by death.location order by death.location, death.date) as rollingpeoplevac
From [Portfolio Projects]..['Covid deaths$'] death
join [Portfolio Projects]..['Covid vac$'] vac
on death.location = vac.location 
and death.date = vac.date
WHERE death.continent is not null 
)
Select *, (rollingpeoplevac/population)*100
from popvsvac

--temp table
drop table if exists #percentpopulationvac
create table #percentpopulationvac
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevac numeric
)

insert into #percentpopulationvac 
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) OVER (partition by death.location order by death.location, death.date) as rollingpeoplevac
From [Portfolio Projects]..['Covid deaths$'] death
join [Portfolio Projects]..['Covid vac$'] vac
on death.location = vac.location 
and death.date = vac.date

Select *, (rollingpeoplevac/population)*100
from #percentpopulationvac

--creating view to store data for visualizations 
create view percentpopulationvac as 
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) OVER (partition by death.location order by death.location, death.date) as rollingpeoplevac
From [Portfolio Projects]..['Covid deaths$'] death
join [Portfolio Projects]..['Covid vac$'] vac
on death.location = vac.location 
and death.date = vac.date
WHERE death.continent is not null 