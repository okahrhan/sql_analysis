SELECT * from ocd_cleaned2 oc 
where oc.location LIKE  "%Turkey%"
--where location = "Turkey"

SELECT * from ocd_cleaned2 oc 
where oc.location LIKE  "%states%"

-- looking at total cases an deadhs

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage from ocd_cleaned2 oc 
where location  like "%states%"
order by 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage from ocd_cleaned2 oc 
where location  like "%states%"
order by total_deaths DESC 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage from ocd_cleaned2 oc 
where location  like "%Turkey%"
order by total_deaths DESC 


-- loking at total cases and population
SELECT location, date, total_cases, population, (total_cases/ population) * 100 AS cases_percentage from ocd_cleaned2 oc 
where location  like "%states%"
order by cases_percentage desc

--

SELECT location, date, new_deaths , MAX(total_cases) as highst_cases , population, MAX((total_cases/population))*100 AS Population_percentage from ocd_cleaned2 oc 
group by location, population 
order by Population_percentage desc	

--


SELECT location, date, max(new_deaths) as ND , MAX(total_cases) as highst_cases , population, MAX((total_cases/population))*100 AS Population_percentage
from ocd_cleaned2 oc
where oc.location like "%Turkey%"
group by date
order by ND DESC 


--showing Countries with highest count per population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ocd_cleaned2 oc
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ocd_cleaned2 oc
Where continent is not null 
Group by continent
order by TotalDeathCount desc


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ocd_cleaned2 oc
where continent is not null 
order by 1,2


SELECT new_vaccinations FROM ocd_cleaned2 oc 
order by new_vaccinations DESC 

-- COVID-19 Vaccination Progress by Country with Rolling Total of Vaccinated People

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INTEGER)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM ocd_cleaned2 dea
JOIN ocd_cleaned2 vac
ON dea.location = vac.location 
AND dea.date = vac.date
ORDER BY dea.location, dea.date;
 
-- PER MONTH

SELECT dea.continent, dea.location, 
STRFTIME('%Y-%m', dea.date) AS month, 
SUM(dea.new_cases) AS mont_case, 
SUM(SUM(dea.new_cases)) OVER (PARTITION BY dea.location ORDER BY STRFTIME('%Y-%m', dea.date)) AS totalCASE
FROM ocd_cleaned2 dea
GROUP BY dea.continent, dea.location, STRFTIME('%Y-%m', dea.date)
ORDER BY dea.location, month;



--The relationship between infections and deaths

WITH Infection_Death AS (
    SELECT location, 
           SUM(new_cases) AS TotalNewCases,
           SUM(new_deaths) AS TotalNewDeaths,
           (SUM(new_deaths) * 1.0 / SUM(new_cases)) * 100 AS deaat_rate
    FROM ocd_cleaned2
    WHERE new_cases > 0 AND new_deaths > 0
    GROUP BY location
),
Infection_Severity AS (
    SELECT idr.location, idr.deaat_rate,
           CASE 
               WHEN idr.deaat_rate > 5 THEN 'high'
               WHEN idr.deaat_rate BETWEEN 2 AND 5 THEN 'middle'
               ELSE 'low'
           END AS SeverityLevel
    FROM Infection_Death  idr
)
SELECT location, deaat_rate, SeverityLevel
FROM Infection_Severity
ORDER BY deaat_rate DESC;



-- avg month death

WITH MonthlyData AS (
    SELECT location, 
           STRFTIME('%Y-%m', date) AS YearMonth,
           SUM(new_deaths) AS MonthlyDeaths
    FROM ocd_cleaned2
    WHERE new_deaths > 0
    GROUP BY location, YearMonth
),
AvgMonthDeaths AS (
    SELECT location,
           AVG(MonthlyDeaths) AS AvgMonthDeaths
    FROM MonthlyData
    GROUP BY location
)
SELECT location, AvgMonthDeaths
FROM AvgMonthDeaths
ORDER BY AvgMonthDeaths DESC;

















