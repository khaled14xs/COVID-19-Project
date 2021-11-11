
-- Covid 19 Data Exploration 
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


Select *
From [dbo].['covid-death$']
Where continent is not null 
order by 3,4



-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [dbo].['covid-death$']
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].['covid-death$']
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [dbo].['covid-death$']
order by 1,2

-- Countries with Highest Infection Rate compared to 


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From  [dbo].['covid-death$']
Group by Location, Population
order by PercentPopulationInfected desc


-- -- Countries with Highest Death Count per Population

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From  [dbo].['covid-death$']
Where  continent is not null 
Group by Location
order by  TotalDeathCount desc


-- Showing contintents with the highest death count per population

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From  [dbo].['covid-death$']
Where  continent is not null 
Group by continent
order by  TotalDeathCount desc 


-- GLOBAL NUMBERS



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From  [dbo].['covid-death$']
where continent is not null 





-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine



Select de.continent, de.location, de.date, de.population, va.new_vaccinations
,SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
from [dbo].['covid-death$'] as de
join [dbo].['covid-vac$'] as va
    on de.location = va.location and de.date = va.date
where de.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].['covid-death$'] as de
Join [dbo].['covid-vac$'] as va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].['covid-death$']as de
Join [dbo].['covid-vac$'] as va
	On de.location = va.location
	and de.date = va.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(int,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated

From [dbo].['covid-death$'] as de
Join [dbo].['covid-vac$'] as va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 




