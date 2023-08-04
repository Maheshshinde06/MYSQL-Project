-- Retrieve all rows from tables data1 and data2
SELECT * FROM project.data1;
SELECT * FROM project.data2;

-- Q1: Number of rows in each dataset
SELECT COUNT(*) FROM project.data1;
SELECT COUNT(*) FROM project.data2;

-- Q2: Dataset for Jharkhand and Bihar
SELECT * FROM project.data1 WHERE state IN ('Jharkhand', 'Bihar');

-- Q3: Population of India
SELECT SUM(population) AS Population FROM project.data2;

-- Q4: Average growth for each state
SELECT state, AVG(growth) * 100 AS avg_growth FROM project.data1 GROUP BY state;

-- Q5: Average sex ratio for each state
SELECT state, ROUND(AVG(sex_ratio), 0) AS avg_sex_ratio FROM project.data1 GROUP BY state ORDER BY avg_sex_ratio DESC;

-- Q6: Average literacy rate for each state, only showing states with an average literacy rate greater than 90
SELECT state, ROUND(AVG(literacy), 0) AS avg_literacy_ratio FROM project.data1
GROUP BY state HAVING ROUND(AVG(literacy), 0) > 90 ORDER BY avg_literacy_ratio DESC;

-- Q7: Top 3 states with the highest growth ratio
SELECT state, AVG(growth) * 100 AS avg_growth FROM project.data1
GROUP BY state ORDER BY avg_growth DESC LIMIT 3;

-- Q8: Bottom 3 states with the lowest sex ratio
SELECT state, ROUND(AVG(sex_ratio), 0) AS avg_sex_ratio FROM project.data1
GROUP BY state ORDER BY avg_sex_ratio ASC LIMIT 3;

-- Q9: Top and bottom 3 states in terms of literacy rate
SELECT state, ROUND(AVG(literacy), 0) AS avg_literacy_ratio FROM project.data1
GROUP BY state ORDER BY avg_literacy_ratio DESC LIMIT 3;

SELECT state, ROUND(AVG(literacy), 0) AS avg_literacy_ratio FROM project.data1
GROUP BY state ORDER BY avg_literacy_ratio ASC LIMIT 3;

-- Q10: Union of top 3 and bottom 3 states based on literacy rate
-- Top 3 states based on literacy rate
WITH topstates AS (
    SELECT state, ROUND(AVG(literacy), 0) AS avg_literacy_ratio
    FROM project.data1
    GROUP BY state
    ORDER BY avg_literacy_ratio DESC
    LIMIT 3
),
-- Bottom 3 states based on literacy rate
bottomstates AS (
    SELECT state, ROUND(AVG(literacy), 0) AS avg_literacy_ratio
    FROM project.data1
    GROUP BY state
    ORDER BY avg_literacy_ratio ASC
    LIMIT 3
)
-- Union of top 3 and bottom 3 states
SELECT * FROM topstates
UNION
SELECT * FROM bottomstates;

-- Q11: States starting with the letter 'a'
SELECT DISTINCT state FROM project.data1 WHERE LOWER(state) LIKE 'a%' OR LOWER(state) LIKE 'b%';

-- Q12: Joining both tables to get the total number of males and females
SELECT d.state, SUM(d.males) AS total_males, SUM(d.females) AS total_females FROM
(SELECT c.district, c.state state, ROUND(c.population / (c.sex_ratio + 1), 0) males, ROUND((c.population * c.sex_ratio) / (c.sex_ratio + 1), 0) females FROM
(SELECT a.district, a.state, a.sex_ratio / 1000 sex_ratio, b.population FROM project.data1 a INNER JOIN project.data2 b ON a.district = b.district) c) d
GROUP BY d.state;

-- Q13: Total literacy rate for each state
SELECT c.state, SUM(literate_people) AS total_literate_pop, SUM(illiterate_people) AS total_illiterate_pop FROM 
(SELECT d.district, d.state, ROUND(d.literacy_ratio * d.population, 0) literate_people, ROUND((1 - d.literacy_ratio) * d.population, 0) illiterate_people FROM
(SELECT a.district, a.state, a.literacy/100 literacy_ratio, b.population FROM project.data1 a 
INNER JOIN project.data2 b ON a.district = b.district) d) c
GROUP BY c.state;

-- Q14: Population in the previous census
SELECT SUM(m.previous_census_population) AS previous_census_population, SUM(m.current_census_population) AS current_census_population FROM(
SELECT e.state, SUM(e.previous_census_population) AS previous_census_population, SUM(e.current_census_population) AS current_census_population FROM
(SELECT d.district, d.state, ROUND(d.population / (1 + d.growth), 0) AS previous_census_population, d.population AS current_census_population FROM
(SELECT a.district, a.state, a.growth, b.population FROM project.data1 a INNER JOIN project.data2 b ON a.district = b.district) d) e
GROUP BY e.state) m;

-- Q15: Output top 3 districts from each state with the highest literacy rate
SELECT a.* FROM
(SELECT district, state, literacy, RANK() OVER (PARTITION BY state ORDER BY literacy DESC) rnk FROM project.data1) a
WHERE a.rnk <= 3
ORDER BY state;