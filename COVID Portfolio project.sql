Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Data Selection for the project

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Totale deaths

-- Shows likelihood of dying if you contract covid in UK

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%kingdom%'
and continent is not null
order by 1,2

-- -- COVID AND COUNTRIES INCOMES

--Death Rate And Countries Income 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%income%'
order by 1,2

--Total Death And Countries Income

Select location ,Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where location like '%income%'
Group by location
order by TotalDeathCount desc



-- Total cases vs Population
--Show percentage of population who got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%kingdom%'
order by 1,2

--Countries with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100
as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc



-- CONTINENTS with the highest DEATH COUNT per population

Select location ,Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- COUNTRIES with Highest DEATH COUNT per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- COUNTRIES with higher rate of death Vs cases

With InfVsDeat
as
(
Select location, population, Max(total_cases) as HighestInfectionCount, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
)

select *, (TotalDeathCount/HighestInfectionCount) *100 as DeathPercentage, (HighestInfectionCount/population) *100 as InfectionRate
from InfVsDeat
order by DeathPercentage desc

-- GLOBAL NUMBERS TOTAL CASES, TOTAL DEATH, DEATH PERCENTAGE

Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath, sum(cast(new_deaths as int))/sum (new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- GLOBAL POPULATION INFECTED PERCENTAGE

Select sum(new_cases) as TotalCases, sum(population) as TotalPopulation, (sum (new_cases)/sum(population)) *100 as CasesPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- GLOBAL NUMBERS DAY BY DAY

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath, sum(cast(new_deaths as int))/sum (new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and total_cases is not null
GROUP by date
order by 1,2

--Total  Population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 

From PopvsVac

-- TEMP TABLE		
drop TABLE iF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
population numeric,
New_Vaccinations numeric,
Rolling_people_vaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (Rolling_people_vaccinated/Population)*100 

From #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION#

use PortfolioProject
go
create view PercentPopulationVaccinated1  as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum (convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null