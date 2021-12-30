select * from CovidProject..CovidDeaths order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths 

--Total cases vs Total deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths

--Total cases vs Total deaths in Pakistan (Chances of dying if you have Covid)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths
where location like '%pakistan%'

--Total cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from CovidProject..CovidDeaths

--Total cases vs Population (% of people getting Covid in Pakistan)

select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from CovidProject..CovidDeaths
where location like '%pakistan%'

--Countries with highest infection rate per population

select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as InfectedPercentage
from CovidProject..CovidDeaths
group by location, population
order by InfectedPercentage desc

--Countries with highest death count per population

select location, max(cast(total_deaths as int)) as DeathCount
from CovidProject..CovidDeaths
where continent is not null
group by location
order by DeathCount desc

--Countries with highest death count per population (by continent)

select continent, max(cast(total_deaths as int)) as DeathCount
from CovidProject..CovidDeaths
where continent is not null
group by continent
order by DeathCount desc

--Global death percentage

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum (cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from CovidProject..CovidDeaths
where continent is not null

--Joining tables
--Total population vs Vaccination

with PopVsVac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location, dea.date) as TotalPeopleVaccinated
from CovidProject..CovidVaccinations vac
join CovidProject..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

)
select *, (TotalPeopleVaccinated/population)*100 
from PopVsVac

--Total population vs Vaccination in Pakistan

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidProject..CovidVaccinations vac
join CovidProject..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.location like '%pakistan%'
order by 2,3

--Creating view to store data and use later

create view PercentPeopleVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location, dea.date) as TotalPeopleVaccinated
from CovidProject..CovidVaccinations vac
join CovidProject..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPeopleVaccinated

