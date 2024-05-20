Select * from PortfolioProject..covid_data;
Select * from PortfolioProject..covid_vaccination;

-- Select data we are going to use
Select Location,total_cases,new_cases,total_deaths,population
from PortfolioProject..covid_data
order by 1,2;

-- Looking at Total cases vs Total Deaths
SELECT 
    Location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM 
    PortfolioProject..covid_data
	where location like '%pakistan%'
	order by Location,date;

-- Looking at total_cases vs total_population
SELECT 
    Location,
    date,
    total_cases,
    population,
    (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT )) * 100 AS populationPercentage
FROM 
    PortfolioProject..covid_data
	where location like '%pakistan%'
	order by Location,date;


-- Looking at countries with highest infection rate compared to population
Select Location,population,Max(total_cases) as HighestinfectionCount, max(total_cases/population)*100 as percentPopulationInfected
from PortfolioProject..covid_data
group by location,population
order by percentPopulationInfected desc;

-- Showing with the highest death count per population
Select Location,Max(cast(total_deaths as int)) as totalDeathCount 
from PortfolioProject..covid_data
where continent is not null
group by location
order by totalDeathCount desc;

-- break things down by continent
Select continent,Max(cast(total_deaths as int)) as totalDeathCount 
from PortfolioProject..covid_data
where continent is not null
group by continent
order by totalDeathCount desc;

Select location,Max(cast(total_deaths as int)) as totalDeathCount 
from PortfolioProject..covid_data
where continent is null
group by location
order by totalDeathCount desc;

-- Continents with the highest deaths
Select continent,Max(cast(total_deaths as int)) as totalDeathCount 
from PortfolioProject..covid_data
where continent is not null
group by continent
order by totalDeathCount desc;



-- Global numbers
SELECT 
 
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100 
    END AS DeathPercentage
FROM 
    PortfolioProject..covid_data
WHERE 
    continent IS NOT NULL

ORDER BY 
    1,2;








-- Now working on second dataset ie covid_vaccination
Select * from PortfolioProject..covid_vaccination;


-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..covid_data dea
    JOIN 
        PortfolioProject..covid_vaccination vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/population)*100 FROM PopvsVac;



-- TEMP TABLES
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinated numeric,
RollingPeopleVaccinated numeric
)
insert into #percentPopulationVaccinated
  SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..covid_data dea
    JOIN 
        PortfolioProject..covid_vaccination vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated


--- CREATING VIEW TO STORE DATA 

-- Create the view
CREATE VIEW percentPopulationVaccinated AS 
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..covid_data dea
JOIN 
    PortfolioProject..covid_vaccination vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

-- Query the view, with optional ordering
SELECT * FROM percentPopulationVaccinated
ORDER BY location, date;
