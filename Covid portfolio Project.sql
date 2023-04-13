Select Location, date,population, total_cases, (total_cases/population)*100
from CovidDeaths
where location like'india'
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
from CovidDeaths
order by 1,2

-- Looiking at countries with the highest infection rate compared to population

select Location, Population, MAX(total_cases) as HighestCases, Max((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc
\
-- highest death count

select Location, MAX(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
where continent is not null
Group by Location
order by totaldeathcount desc



--order by continent

select Location, MAX(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
where continent is  null
Group by Location
order by totaldeathcount desc

-- Showing the continents with highest death count per populatoion


select Continent, MAX(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
where continent is not null
Group by Continent
order by totaldeathcount desc

--global numbers

Select  date,sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,  sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
, max(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea. date =  vac.date 
where dea.continent is not null 
order by 2,3

-- USE CTE

With PopvsVac(Continent, location, date, population, new_vaccinations,RollingPeopleVacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--, max(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea. date =  vac.date 
where dea.continent is not null 
--order by 2,3
)
Select * , (RollingPeopleVacinated/Population)*100
from PopvsVac



--TEMP TABLE


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--, max(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea. date =  vac.date 
--where dea.continent is not null 
--order by 2,3


Select *,  (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated 

-- Creating viw to store data for later visualisation

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location Order by
dea.location, dea.date) as RollingPeopleVaccinated
--, max(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea. date =  vac.date 
where dea.continent is not null 
--order by 2,3



Select *
From PercentPopulationVaccinated
