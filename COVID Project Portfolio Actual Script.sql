/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from CovidDeath$
where continent is not null
order by 3,4


select *
from CovidVacination$
where continent is not null
order by 3,4


--select the data we are going to be using


select location,date,total_cases,new_cases,total_deaths,population
from CovidDeath$
where continent is not null
order by 1,2


--total deaths vs total cases 
--shows the likelihood of dying if you contract covid in your country


select location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from CovidDeath$
--where location like '%Pakistan%'
where continent is not null
order by 1,2


--looking at the total cases vs population
--shows what perecentage of population got covid


select location,date,population,total_cases,(cast(total_deaths as float)/population)*100 as PerentagePopulationInfected
from CovidDeath$
--where location like '%Pakistan%'
where continent is not null
order by 1,2


--looking at the countries which have high infection rate compared to popultion


select location,population,max(cast(total_deaths as float)) as HighestInfectionCount,(max(cast(total_deaths as float))/population)*100 as PerentagePopulationInfected
from CovidDeath$
--where location like '%Pakistan%'
where continent is not null
group by location,population
order by PerentagePopulationInfected desc


--showing countries with the highest death count per population


select location,max(cast(total_deaths as float)) as TotalDeathCount
from CovidDeath$
--where location like '%Pakistan%'
where continent is not null
group by location,population
order by TotalDeathCount desc


--lets brings things dwon by continents
--showing countries with the highes death count per population


select location,max(cast(total_deaths as float)) as TotalDeathCount --continent
from CovidDeath$
--where location like '%Pakistan%'
where continent is null --not null
group by location --continent
order by TotalDeathCount desc


--global numbers


select SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths,(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage --date
from CovidDeath$
--where location like '%Pakistan%'
where continent is not null
--group by date
having SUM(new_cases) > 0 and SUM(new_deaths) > 0
order by 1,2


--looking at total population vs vaccintions


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
from CovidDeath$ as dea
join CovidVacination$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and vac.new_vaccinations is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
from CovidDeath$ as dea
join CovidVacination$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and vac.new_vaccinations is not null
--order by 2,3--
)
select * ,(RollingPeopleVaccinated/population)*100
from popvsvac


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
from CovidDeath$ as dea
join CovidVacination$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null-- --and vac.new_vaccinations is not null
order by 2,3--

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
from CovidDeath$ as dea
join CovidVacination$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null-- --and vac.new_vaccinations is not null
--order by 2,3--
