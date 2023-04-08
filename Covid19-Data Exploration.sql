select * from ProjectCovid..CovidDeathsnew order by 3,4
select * from ProjectCovid..CovidVaccinationnew order by 3,4
select * from ProjectCovid..CovidDeathsnew where continent is not null order by 3,4

---------- Select Data that we are going to be using---------------

select Location,date,new_cases,total_cases,total_deaths,population 
from ProjectCovid..CovidDeathsnew order by 1,2

----------Looking at Total Cases vs Total Deaths--------------
--------Shows likelihood of dying if you contract covid in your country---------
select Location,date,total_cases,total_deaths,
      (total_deaths/total_cases) * 100 as DeathPercentage 
from ProjectCovid..CovidDeathsnew order by 1,2


select Location,date,total_cases,total_deaths,
      (total_deaths/total_cases) * 100 as DeathPercentage 
from ProjectCovid..CovidDeathsnew 
where location like '%states%'
and continent is not null
order by 1,2
 
 --Looking at Total Cases vs Population---------------
 --Shows what percentage of population got Covid
select Location,date,Population,total_cases,
        (total_cases/population)*100 as case_Percentage 
from ProjectCovid..CovidDeathsnew 
where location like '%states%'
order by 1,2


select Location,date,Population,total_cases,(total_cases/population)*100 as PercentPopulationInfected 
from ProjectCovid..CovidDeathsnew 
order by 1,2                              --(For visaulisation p....)



----------Looking at Countries with Highest Infection rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount,
       max((total_cases/population))*100 as PercentPopulationInfected
from ProjectCovid..CovidDeathsnew
--where location like '%States%'
group by location,population
order by PercentPopulationInfected desc


--Showing Countries with Death Count per Population----
select location,max(total_deaths) as TotalDeathCount
from ProjectCovid..CovidDeathsnew
--where location like '%states'
group by location
order by TotalDeathCount desc
      --(Here, Aggregate function max() works on varchar(255) datatype of total_death column so we are converting nVARCHAR to INT datatype)--- 

select location,max(cast(total_deaths as int)) as TotalDeathCount
from ProjectCovid..CovidDeathsnew
--where location like '%states'
group by location
order by TotalDeathCount desc

select location,max(cast(total_deaths as int)) as TotalDeathCount
from ProjectCovid..CovidDeathsnew
--where location like '%states'
where continent is not null
group by location
order by TotalDeathCount desc

--------------Let's Break things down by continent

--Showing continents with highest death count per population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from ProjectCovid..CovidDeathsnew
--where location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc


-----------------------------GLOBAL NUMBERS---------
select date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from ProjectCovid..CovidDeathsnew
--where location like '%states%'
where continent is not null
group by date
order by 1,2--(This is not execute because it is not contained in either an aggregate function or the GROUP BY clause.) 



select date,sum(new_cases) as total_cases,
       sum(cast(new_deaths as int)) as total_deaths,
       sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectCovid..CovidDeathsnew
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--Overall across the world deathpercentage
select sum(new_cases) as total_cases,
       sum(cast(new_deaths as int)) as total_deaths,
       sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectCovid..CovidDeathsnew
--where location like '%states%'
where continent is not null
order by 1,2





-------------------------------------------------------------------------------------------------------------
select * 
from ProjectCovid..CovidDeathsnew Dea
join ProjectCovid..CovidVaccinationnew Vac
     On  Dea.location = Vac.location
	 and Dea.date     = Vac.date
---------------------------------------------------------------------------------------------

--Looking at Total Population vs Vaccinations
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as bigint)) over(partition by Dea.location ORDER by dea.location,Dea.date)
from ProjectCovid..CovidDeathsnew Dea
Join ProjectCovid..CovidVaccinationnew Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

---Use CTE
with PopvsVac (continent,location,date,population,new_vaccination,rollingPeopleVaccinated)
as
(
select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location Order by dea.location,dea.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated)*100
from ProjectCovid..CovidDeathsnew Dea
Join ProjectCovid..CovidVaccinationnew Vac
	On  Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)
select * from PopvsVac
select *,(rollingPeopleVaccinated/population)*100 from PopvsVac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjectCovid..CovidDeathsnew Dea
Join ProjectCovid..CovidVaccinationnew Vac
	on  dea.location = Vac.location
	and dea.date = Vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


----------Creating View to store date for later Visualizations----
Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjectCovid..CovidDeathsnew Dea
Join ProjectCovid..CovidVaccinationnew Vac
	on  dea.location = Vac.location
	and dea.date = Vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated





