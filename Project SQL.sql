create database energy_consumptiondb;
use energy_consumptiondb;
create table country (
    country varchar(100) primary key,
    cid varchar(10)
);

-- consumer table
create table consumer (
    country varchar(100),
    energy varchar(100),
    year int,
    consumption decimal(15,5),
    foreign key (country) references country(country)
);

-- emission table
create table emission (
    country varchar(100),
    energy_type varchar(100),
    year int,
    emission decimal(20,5),
    per_capita_emission decimal(20,5),
    foreign key (country) references country(country)
);

-- gdp_3 table
create table gdp_3 (
    country varchar(100),
    year int,
    value decimal(20,5),
    foreign key (country) references country(country)
);

-- population table
create table population (
    country varchar(100),
    year int,
    value decimal(15,5),
    foreign key (country) references country(country)
);

-- production table
create table production (
    country varchar(100),
    energy varchar(100),
    year int,
    production decimal(38,10),
    foreign key (country) references country(country)
);

-- 1. Total emission per country for the most recent year
select country, sum(emission) as total_emission
from emission
where year = (select max(year) from emission)
group by country
order by total_emission desc;

-- 2. Top 5 countries by GDP in the most recent year
select country, value as gdp
from gdp_3
where year = (select max(year) from gdp_3)
order by value desc
limit 5;

-- 3. Compare energy production & consumption by country & year
select p.country, p.year, p.production, c.consumption
from production p
join consumer c
  on p.country = c.country and p.year = c.year
order by p.country, p.year;

-- 4. Which energy types contribute most to emissions
select energy_type, sum(emission) as total_emission
from emission
group by energy_type
order by total_emission desc;

-- 5. Global emissions trend year by year
select year, sum(emission) as global_emissions
from emission
group by year
order by year;

-- 6. Trend in GDP per country
select country, year, value as gdp
from gdp_3
order by country, year;

-- 7. Effect of population growth on total emissions
select e.country, e.year, sum(e.emission) as total_emission,
       p.value as population,
       (sum(e.emission) / p.value) as emission_per_capita_calc
from emission e
join population p
  on e.country = p.country and e.year = p.year
group by e.country, e.year, p.value
order by e.country, e.year;

-- 8. Energy consumption trend per country
select country, year, sum(consumption) as total_consumption
from consumer
group by country, year
order by country, year;

-- 9. Average yearly change in per-capita emissions
select country, avg(per_capita_emission) as avg_yearly_percapita_emission
from emission
group by country
order by avg_yearly_percapita_emission desc;

-- 10. Emission-to-GDP ratio
select e.country, e.year, sum(e.emission) / g.value as emission_to_gdp_ratio
from emission e
join gdp_3 g
  on e.country = g.country and e.year = g.year
group by e.country, e.year, g.value
order by emission_to_gdp_ratio desc;

-- 11. Energy consumption per capita
select c.country, c.year, (c.consumption / p.value) as consumption_per_capita
from consumer c
join population p
  on c.country = p.country and c.year = p.year
order by c.country, c.year;

-- 12. Energy production per capita
select p.country, p.year, (p.production / pop.value) as production_per_capita
from production p
join population pop
  on p.country = pop.country and p.year = pop.year
order by p.country, p.year;

-- 13. Highest energy consumption relative to GDP
select c.country, c.year, sum(c.consumption) / g.value as consumption_to_gdp_ratio
from consumer c
join gdp_3 g
  on c.country = g.country and c.year = g.year
group by c.country, c.year, g.value
order by consumption_to_gdp_ratio desc;

-- 14. Correlation between GDP & Energy Production
select p.country, p.year, p.production, g.value as gdp
from production p
join gdp_3 g
  on p.country = g.country and p.year = g.year
order by p.country, p.year;

-- 15. Top 10 countries by population & emissions
select p.country, p.value as population, sum(e.emission) as total_emission
from population p
join emission e
  on p.country = e.country and p.year = e.year
where p.year = (select max(year) from population)
group by p.country, p.value
order by population desc
limit 10;

-- 16. Countries that reduced emissions per capita most
select country,
       min(per_capita_emission) as earliest_value,
       max(per_capita_emission) as latest_value,
       (min(per_capita_emission) - max(per_capita_emission)) as reduction
from emission
group by country
order by reduction desc;

-- 17. Global share of emissions
select country,
       sum(emission) / (select sum(emission) from emission) * 100 as global_share_percentage
from emission
group by country
order by global_share_percentage desc;

-- 18. Global average GDP, Emission & Population by year
select g.year,
       avg(g.value) as avg_gdp,
       (select avg(emission) from emission e where e.year = g.year) as avg_emission,
       (select avg(value) from population p where p.year = g.year) as avg_population
from gdp_3 g
group by g.year
order by g.year;

-- 19. Identify countries with higher consumption than production
select c.country,
       c.year,
       c.consumption,
       p.production,
       (c.consumption - p.production) as deficit
from consumer c
join production p
  on c.country = p.country and c.year = p.year
where c.consumption > p.production
order by deficit desc;

-- 20. Rank countries by average emissions over all years
select country,
       avg(emission) as avg_emission
from emission
group by country
order by avg_emission desc;

