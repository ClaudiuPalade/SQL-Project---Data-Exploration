
/*  SQL data exploration project : COVID-19, vaccinations and deaths
	Global data extracted from  https://ourworldindata.org/coronavirus
	RDBMS used : Microsoft SQL Server  */

-- Total cases vs total deaths in Romania
-- Likelihood of dying if you contract Covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 As Death_Percentage
From Covid_Deaths
Where location = 'Romania'
Order by 1, 2;

-- Total cases vs population in Romania
-- Percentage of population infected

Select location, date, total_cases, population, (total_cases/population) * 100 As Covid_Cases_Percentage
From Covid_Deaths
Where location = 'Romania'
Order by 1, 2;

-- Countries with highest infection rates compared to population

Select location, MAX(total_cases) As Highest_Infection_Count, population, MAX((total_cases/population) * 100) As Covid_Cases_Percentage
From Covid_Deaths
Group By location, population
Order By Covid_Cases_Percentage DESC;

-- Countries with highest death count per population

Select location, MAX(Cast(total_deaths As int)) as Total_Death_Count
From Covid_Deaths
Where continent IS NOT NULL
Group By location
Order By 2 DESC;

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths As int)) as total_deaths, SUM(Cast(new_deaths As int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_Deaths
where continent IS NOT NULL 
order by 1,2;

-- Rolling vaccinations in Romania

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vacs, 
SUM(Cast(vac.new_vacs As bigint)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingVaccinations
From Covid_Deaths As dea
Join Covid_Vaccinations As vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null AND dea.location = 'Romania';

-- Using a CTE to perform calculation on Partition By in previous query
-- Shows also rolling percentage of vaccinations in total population

With PercPopVac (Continent, Location, Date, Population, New_Vacs, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vacs
, SUM(CONVERT(int,vac.new_vacs)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From Covid_Deaths As dea
Join Covid_Vaccinations As vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null AND dea.location = 'Romania'

)
Select *, (RollingVaccinations/Population)*100 As Perc_Vacs_In_Pop
From PercPopVac

-- View creation for later visualizations

Create View RollingVacs as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vacs, 
SUM(CONVERT(int,vac.new_vacs)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From Covid_Deaths As dea
Join Covid_Vaccinations As vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent Is Not Null;

