
Select *
From Project.dbo.coviddeath
where continent is not null 
Order by 3,4

--Select *
--From Project.dbo.covidvaccination 
--Order by 3,4

--Select data we are going to be using .

Select Location,date,total_cases,new_cases,total_deaths, population
from Project.dbo.coviddeath
order by 1,2

--total cases vs total deaths


Select location,date,total_cases,total_deaths,(convert(float,total_deaths)/ Nullif(convert(float,total_cases),0))*100 as DeathPercentage
From Project..coviddeath
where location like'%india%'
order by 1,2

-- total cases vs population

Select location,date,total_cases,population,(convert(float,total_cases)/ Nullif(convert(float,population),0))*100 as DeathPercentage
From Project..coviddeath
where location like'%india%'
order by 1,2

--Showing countries highest death

select location,max(cast(total_deaths as int)) as TotalDeathCount
from project.dbo.coviddeath
where continent is not null 
group by location
order by TotalDeathCount desc

-- Continent wise analysis 
select location,max(cast(total_deaths as int)) as TotalDeathCount

from project.dbo.coviddeath
where continent is  null 
group by location
order by TotalDeathCount desc

--looking at total population vs vaccination

Select dea.continent,dea.location , dea.date, dea.population, vac.new_vaccinations ,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from project.dbo.coviddeath dea
join project.dbo.covidvaccination vac
   on dea.location = vac.location 
   and dea.date=vac.date
   order by 1,2,3

   -- using CTE

  with PopvsVac(continent, location, date ,population , new_vaccinations, RollingPeopleVaccinated)
   as 
  ( 
Select dea.continent,dea.location , dea.date, dea.population, vac.new_vaccinations ,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from project.dbo.coviddeath dea
join project.dbo.covidvaccination vac
   on dea.location = vac.location 
   and dea.date=vac.date
  --order by 1,2,3
  )
  Select *
from PopVsVac

  -- temp table
  drop table if exists #percentagepopulationvaccinated
  Create table #percentagepopulationvaccinated
(
continent nvarchar(225),
location  nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccincated numeric
)



  insert into #percentagepopulationvaccinated
  Select dea.continent,dea.location , dea.date, dea.population, vac.new_vaccinations ,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from project.dbo.coviddeath dea
join project.dbo.covidvaccination vac
   on dea.location = vac.location 
   and dea.date=vac.date
  -- order by 1,2,3

  Select *, (RollingPeopleVaccinated/population)*100
  from #percentagepopulationvaccinated

  -- creating view for later visualization 

  create view Percentpopulationvaccinated as 
    Select dea.continent,dea.location , dea.date, dea.population, vac.new_vaccinations ,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from project.dbo.coviddeath dea
join project.dbo.covidvaccination vac
   on dea.location = vac.location 
   and dea.date=vac.date
   where dea.continent is not null
  --order by 2,3

  Select *
  From PercentPopulationVaccinated