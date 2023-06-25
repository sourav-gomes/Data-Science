--select * from [PortfolioProject1]..CovidDeaths
order by 3,4

--select * from [PortfolioProject1]..CovidVaccinations
--order by 3,4

select  location,date new_cases, total_cases, total_deaths, population
from PortfolioProject1..Covid_Deaths
Where continent is not null
order by location

-- Looking at Total cases Vs Total Deaths
-- Shows the possibility of dying if you contract COVID in your country

select  location, date, total_cases, total_deaths, (total_deaths/convert(float,total_cases))*100 as '%MortalityRate'
from PortfolioProject1..Covid_Deaths
where location = 'India'
and continent is not null
order by location, date


-- Looking at Total cases Vs Population
-- Shows what population of Covid has got Covid in a country

select  location, date, total_cases, population, (cast(total_cases as float)/population)*100 as '%CovidContractionRate'
from PortfolioProject1..Covid_Deaths
where location like '%states'
and continent is not null
order by 1, 2

-- Looking at the countries with Highest Infection Rate

select  location, population, max(total_cases) as HighestInfectionCount, max((convert(float, total_cases)/population)*100) as '% MaxCovidContractionRate'
from PortfolioProject1..Covid_Deaths
Where continent is not null
AND location like 'India'
group by location,population
order by '% MaxCovidContractionRate' desc


select  location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as '% MaxCovidContractionRate'
from PortfolioProject1..CovidDeaths
Where continent is not null
group by location,population
order by '% MaxCovidContractionRate' desc


-- Showing countries with Highest Death count per Population

Select Location, Max(total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc


-- Let's break things up by continent
-- Showing continent with highest Death Count

Select continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--More accurate
Select location, Max(total_deaths) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is null
and location not in ('World','High income','Upper middle income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc


--Global NUmbers

select sum(new_cases) As Total_Cases_Globally, sum(new_deaths) Total_Deaths_Globally, 
sum(new_deaths)/sum(new_cases)*100 as '% GlobalMortalityRate'
from PortfolioProject1..CovidDeaths
where continent is not null
--group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..Covid_Deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Polulation Vs Vaccination
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
from PortfolioProject1..CovidDeaths dea
	join PortfolioProject1..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Do a Rolling Total
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(Partition by dea.location order by dea.location, dea.date) as RollingNoOfVaccinations
from PortfolioProject1..CovidDeaths dea
	join PortfolioProject1..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null 
and dea.location = 'United states'
order by 2,3



-- USE CTE - To calculate the Rolling %

WITH PopVsVac (Date, Continent, Location, Population, New_Vaccination, RollingNoOfVaccinations)
as
(
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(Partition by dea.location order by dea.location, dea.date) as RollingNoOfVaccinations
from PortfolioProject1..CovidDeaths dea
	join PortfolioProject1..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null 
and dea.location = 'Albania'
--order by 2,3
)
select PopVsVac.continent, PopVsVac.location, PopVsVac.population, PopVsVac.New_vaccination, (RollingNoOfVaccinations / Population)*100 As Rolling_Percentage_of_Vaccinations
from PopVsVac



-- TEMP TABLE

DROP TABLE if exists #Temp_PercentPeopleVaccinated
create table #Temp_PercentPeopleVaccinated (
Date datetime, 
Continent nvarchar(255), 
Location nvarchar(255), 
Population numeric, 
New_Vaccination numeric, 
RollingNoOfVaccinations numeric)

INSERT INTO #Temp_PercentPeopleVaccinated
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(Partition by dea.location order by dea.location, dea.date) as RollingNoOfVaccinations
from PortfolioProject1..CovidDeaths dea
	join PortfolioProject1..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null 
--and dea.location = 'Albania'
--order by 2,3

select * from #Temp_PercentPeopleVaccinated


-- Creating Views for later Visualisations
-- DROP VIEW if exists PercentPeopleVaccinated


CREATE VIEW PercentPeopleVaccinated AS
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(Partition by dea.location order by dea.location, dea.date) as RollingNoOfVaccinations
from PortfolioProject1..CovidDeaths dea
	join PortfolioProject1..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPeopleVaccinated


------------------------
