/*
ALTERING TABLE:
    "ALTER TABLE"
 - ALTER TABLE table_name
 -- ADD column_name datatype;
 -- RENAME COLUMN column_name TO new_namel
 -- ALTER COLUMN column_name TYPE datatype;
 -- DROP COLUMN column_name;
*/

-- ----------------
/* Handling Dates 
 ::DATE :Converts to a date format by removing the time portion
 AT TIME ZONE :Converts a timestamp to a specified time zone
 EXTRACT: Gets specific date parts (e.g. year, month, day)
*/
-- ---------------
-- ---------------
SELECT '2025-03-19'::DATE,
    '123'::INTEGER,
    'true'::BOOLEAN,
    '3.14'::REAL;

SELECT
    job_title_short AS title,
    job_location AS location,
   -- job_posted_date AS date
    job_posted_date::DATE as date
FROM job_postings_fact
LIMIT 100;

--TIMESTAMP with TIMEZONE: AT TIME ZONE
--code below first selects the timezone then swaps with the later one
/* SELECT column_Name AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
   FROM table_name;
*/
SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date
FROM job_postings_fact
LIMIT 100;
-- ----------------

-- ----------------
-- EXTRACT - gets field( year, month, day) from a date/time value
/*
SELECT
    EXTRACT(MONTH FROM column_name) AS column_month
FROM table_name;
*/
SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date,
    EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM job_postings_fact
LIMIT 100;
-- ----------------

-- ------------
-- How job trends from months to months?
-- --Expanded: for data engineer
-- --        - for data analyt
-- ------------
SELECT
    COUNT (job_id) AS total_job_postings,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM
    job_postings_fact
WHERE
    --job_title_short='Data Engineer'    
    job_title_short='Data Analyst'    
GROUP BY
    month
ORDER BY
    total_job_postings DESC;        
-- ------------

-- ------------
/* 
CASE expression: if else statement> conditional statement
EG> 
    SELECT
        CASE
            WHEN column_name='Value1' THEN 'Description for Value1'
            WHEN column_name='Value2' THEN 'Description for Value2'
            ELSE 'Other'
        END AS column_description
    FROM table_name            
*/

/*
Label new column as follows:
    - 'Anywhere' jobs as 'Remote'
    - 'New York, NY' jobs as 'Local'
    - Otherwise 'Onsite'
 */
SELECT
    job_title_short,
    job_location,
    CASE
        WHEN job_location='Anywhere' THEN 'Remote'
        WHEN job_location='New York, NY' THEN 'Local'
        ELSE 'Onsite'    
    END AS location_category
FROM job_postings_fact;

-- Like last one but AGGREGATED for better results
SELECT
    COUNT(job_id) AS number_of_jobs,
    job_title_short,
    job_location,
    CASE
        WHEN job_location='Anywhere' THEN 'Remote'
        WHEN job_location='New York, NY' THEN 'Local'
        ELSE 'Onsite'    
    END AS location_category
FROM job_postings_fact
GROUP BY
    location_category,
--now i have to other 2 column cause they arent inside AGGREGATE FUNCTION(Dumbass SQL rule)
    job_location,
    job_title_short;

 -- What I actually wanted
SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location='Anywhere' THEN 'Remote'
        WHEN job_location='New York, NY' THEN 'Local'
        ELSE 'Onsite'    
    END AS location_category
FROM job_postings_fact
WHERE
    job_title_short='Data Engineer'
GROUP BY
    location_category;
-- ------------
-- ------------


/*
===================
Subqueries and CTEs
===================
 Subqueries and Common Table Expressions(CTEs): Used for organizing and simplifying
 complex queries.
- helps break down the query into smaller, more manageable parts
- when to use one over other?
  > Subqueries are for simpler queries
  > CTes are for more complex queries
*/

-- Subqueries: query nested inside a larger query
-- Can be used in SELECT, FROM, WHERE, HAVING caluse
SELECT * FROM(-- sub query starts here
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date)=1
) AS january_jobs;
-- ------------------
-- ------------------
/* CTE: Common Table Expresions 
    > Can reference within a SELECT, INSERT, UPDATE or DELETE
    > Defined with WITH
*/
WITH january_jobs AS (--CTE defination starts here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date)=1    
)
SELECT *
FROM january_jobs;
-- -------------
-- -------------

-- SUBQUERY in action
SELECT
    company_id,
    job_no_degree_mention
FROM
    job_postings_fact
WHERE
    job_no_degree_mention=true;
-- Trying to get the jobs with associated company_ids
-- then filter inside company_dim table
SELECT
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN(
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention=true
);

-- ----------
-- ----------
/* CTE: Finding companies that have the most job openings
    - Get the total number job job postings per company_id
    - Return the total number of jobs with the company name*/
WITH company_job_count AS(
    SELECT company_id,
        COUNT(*) AS total_job_openings
    FROM job_postings_fact
    GROUP BY
        company_id
)
SELECT 
    company_dim.name AS company_name,
    company_job_count.total_job_openings
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id=company_dim.company_id
ORDER BY 
    total_job_openings DESC;

-- --------
 --Find the count of the number of remote job postings per skill
 --
 -- -display the top 5 skills by their demand in remote jobs
 -- -Include skill ID,name and count of postings requiring the skill
-- --------

WITH remote_job_skills AS(
    SELECT
        skill_id,
        COUNT(*) AS skill_count
     -- job_postings.job_work_from_home
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id=skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home= True
        AND job_postings.job_title_short = 'Data Analyst'
    GROUP BY
        skill_id
)
SELECT skill.skill_id,
    skill.skills AS skill_name,
    skill_count
FROM remote_job_skills 
INNER JOIN skills_dim AS skill ON skill.skill_id=remote_job_skills.skill_id
ORDER BY skill_count DESC;
-- LIMIT 5;     

-- ----------------
-- ----------------
-- UNION Operators
-- Combine result sets of two or more SELECT satetements into a single result set.
--     UNION: Remove duplicate rows
--     UNION ALL: Includes duplicate rows
-- <^>NB: Each SELECT satement within the UNION must have the same number of column
--        in the result sets with similar data types
SELECT
    job_title_short,
    company_id,
    job_location
FROM january_jobs
UNION ALL
SELECT
    job_title_short,
    company_id,
    job_location
FROM february_jobs
UNION ALL
SELECT
    job_title_short,
    company_id,
    job_location
FROM march_jobs