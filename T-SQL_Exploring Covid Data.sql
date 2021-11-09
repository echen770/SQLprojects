-- specify the database for query
use portfolio1;
go

-- select the data for this project
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_death
WHERE continent is NOT NULL
ORDER BY location, date;

-- Looking at total deaths vs total cases

-- Likelihood of dying from covid, result organized by country
SELECT location, date, total_deaths, total_cases, FORMAT(total_deaths/total_cases, 'P') AS death_percentage, population
FROM covid_death
WHERE continent is NOT NULL
ORDER BY location, date;

-- Covid cases vs population, results organized by country
SELECT location, date, total_cases, population, FORMAT(total_cases/population, 'P') AS case_percentage
FROM covid_death
WHERE continent is NOT NULL
ORDER BY location, date;

-- List countries with the highest infection rate
SELECT location, cd.date, total_cases, population, FORMAT(ISNULL(total_cases/population, 0), '00.00%') AS max_case_percentage
FROM covid_death cd
WHERE continent is NOT NULL and cd.date in (
	SELECT MAX(date) FROM covid_death
)
ORDER BY max_case_percentage desc, location;

-- List countries with the highest infection rate
SELECT location, ISNULL(MAX(CONVERT(int,total_cases)), 0) as highest_infection_count, population, FORMAT(ISNULL(MAX(total_cases/population), 0), '00.00%') AS max_case_percentage
FROM covid_death
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY max_case_percentage desc, location;

-- highest death count
SELECT location, cd.date, total_deaths, population, FORMAT(ISNULL(total_deaths/population, 0), '00.00%') AS max_death_percentage
FROM covid_death cd
WHERE continent is NOT NULL and total_deaths is not null and cd.date in (
	SELECT MAX(date) FROM covid_death
)
ORDER BY max_death_percentage desc, location;

-- maximum death count by country
SELECT location, MAX(convert(int,total_deaths)) as max_death_count
FROM covid_death
WHERE continent is NOT NULL and total_deaths is not null
GROUP BY location
ORDER BY max_death_count desc;

-- Total death count by continent
SELECT continent, FORMAT(SUM(convert(int,total_deaths)), 'N0') as max_death_count
FROM covid_death cd
WHERE continent is NOT NULL and cd.date in (
	SELECT MAX(date) FROM covid_death
)
GROUP BY continent
ORDER BY max_death_count desc;

-- Global death percentages
with cte_death_vs_case as (
SELECT cd.date, SUM(convert(decimal,total_deaths)) as total_death_count, SUM(convert(decimal,total_cases)) as total_case_count
FROM covid_death cd
WHERE continent is NOT NULL AND cd.date in (
	SELECT MAX(date) FROM covid_death
)
GROUP BY date
)
select
	CONVERT(nvarchar,date,110) as report_date,
	FORMAT(total_death_count, 'N0') as deaths,
	FORMAT(total_case_count, 'N0') as cases, 
	format(total_death_count/total_case_count, '0.00%') as death_percentage
from cte_death_vs_case;



-- Global case percentages
with cte_case_vs_population as (
SELECT cd.date, SUM(convert(decimal,total_cases)) as total_case_count, SUM(convert(decimal,population)) as total_population
FROM covid_death cd
WHERE continent is NOT NULL AND cd.date in (
	SELECT MAX(date) FROM covid_death
)
GROUP BY date
)
select
	CONVERT(nvarchar,date,110) as report_date,
	FORMAT(total_case_count, 'N0') as cases,
	FORMAT(total_population, 'N0') as population, 
	format(total_case_count/total_population, '0.00%') as case_percentage
from cte_case_vs_population;

-- at least one does vaccinations vs population by country or region
SELECT cd.location, cd.date,
	FORMAT(convert(decimal,people_vaccinated), 'N0') AS one_does_vaccinated, 
	FORMAT(convert(decimal,population), 'N0') AS total_population, 
	FORMAT(cast(people_vaccinated as decimal) / cast(population as decimal), '00.00%') AS one_does_vaccination_rate
FROM covid_death cd
JOIN covid_vac cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	AND people_vaccinated IS NOT NULL
	AND cd.date IN (
	SELECT MAX(date) as max_date FROM covid_death
	)
ORDER BY one_does_vaccination_rate desc;

-- full vaccinations vs population by country or region
SELECT cd.location, cd.date,
	FORMAT(convert(decimal,people_fully_vaccinated), 'N0') AS fully_vaccinated, 
	FORMAT(convert(decimal,population), 'N0') AS total_population, 
	FORMAT(cast(people_fully_vaccinated as decimal) / cast(population as decimal), '00.00%') AS full_vaccination_rate
FROM covid_death cd
JOIN covid_vac cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	AND people_fully_vaccinated IS NOT NULL
	AND cd.date IN (
	SELECT MAX(date) as max_date FROM covid_death
	)
ORDER BY full_vaccination_rate desc;

-- rolling vaccination count vs population (vaccination rate can get over 100% due to two-does vaccines being counted twice)
WITH cte_vac_pop AS (
SELECT cd.location, cd.date, cv.new_vaccinations, cv.total_vaccinations, cd.population,
	SUM(CAST(cv.new_vaccinations AS decimal)) OVER (PARTITION BY cd.location order by cd.location, cd.date) AS rolling_vaccination_count
FROM covid_death cd
JOIN covid_vac cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT location, date, FORMAT(population, 'N0') AS total_population, FORMAT(CAST(total_vaccinations AS decimal), 'N0') AS total_vac, FORMAT(CAST(new_vaccinations AS decimal), 'N0') AS new_vac, FORMAT(rolling_vaccination_count, 'N0') AS rolling_vac_count, FORMAT(rolling_vaccination_count/population, 'P') as rolling_vac_rate
FROM cte_vac_pop
ORDER BY location, date