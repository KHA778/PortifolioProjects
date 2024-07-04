Select *
From CovidDeath
where continent is not Null
order by 3,4

--Select *
--From CovidVaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeath
order by 1,2

--looking at the total cases vs total deaths
--Shows the likelyhood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathporcentage
from CovidDeath
where location like '%Brazil%'
order by 1,2

--Total cases vs the population

select location, date, total_cases, population, (total_cases/population)*100 as PorcentegePopulationWithCovid
from CovidDeath
--where location like '%Brazil%'
order by 1,2

--Country with the highest infaction rate compared to population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PorcentegePopulationWithCovid
from CovidDeath
--where location like '%Brazil%'
group by location,population
order by PorcentegePopulationWithCovid desc


--showing the country with the highest death count by population


select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
--where location like '%Brazil%'
where continent is not Null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continent with the highest death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
--where location like '%Brazil%'
where continent is Null
group by location
order by TotalDeathCount desc

--Global Numbers

select  sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathporcentage
from CovidDeath
--where location like '%Brazil%'
where continent is not Null
--group by date
order by 1,2


--looking at total population vs total vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeath dea
join CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
 
--USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeath dea
join CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table
Drop table if exists #PorcentegePopulationVaccinated
create table #PorcentegePopulationVaccinated
(
Continet nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)



Insert Into  #PorcentegePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeath dea
join CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from  #PorcentegePopulationVaccinated

--create view to store data for later visualizations
create view PopulationWithCovid as
select location, date, total_cases, population, (total_cases/population)*100 as PorcentegePopulationWithCovid
from CovidDeath
--where location like '%Brazil%'




