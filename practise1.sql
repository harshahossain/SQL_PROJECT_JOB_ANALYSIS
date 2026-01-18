/*
Query to find the average salary for both yearly and hourly
for job postings that were posted after 1st June, 2023 
group results by job schedule type
*/

SELECT
    job_schedule_type AS schedule_type,
    AVG(salary_year_avg) AS yearly_avg_salary,
    AVG(salary_hour_avg) AS hourly_avg_salary
FROM job_postings_fact
WHERE
    job_posted_date>'2023-06-01'
GROUP BY
    schedule_type;    
-- ---------------------------------------

/*
Query to count the number of job postings for each month in 2023,
adjusting the job_posted_date to be in 'America/New_York' time zone
Before extracting the month, assume the job_posted_date is stored in UTC.
Group by and Order by Month
*/
SELECT
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month_no,
    COUNT(job_id) AS job_count
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') = 2023
GROUP BY
    month_no
ORDER BY
    month_no;
-- ---------------------------------------

/*
Query to find companies(include company name) that have posted jobs offering health
insurance, where these postings were made in the second quarter of 2023. Use date
extraction to filter by quarter
*/
SELECT 
    cd.name AS company_name,
    jpf.job_health_insurance,
    jpf.job_posted_date
FROM
    job_postings_fact AS jpf
    INNER JOIN
        company_dim AS cd ON jpf.company_id=cd.company_id
WHERE
    jpf.job_health_insurance=TRUE
    AND EXTRACT(QUARTER FROM jpf.job_posted_date)=2
    AND EXTRACT(YEAR FROM jpf.job_posted_date)=2023;


-- SELECT * FROM job_postings_fact LIMIT 10;

-- -----------------------------------------
/*
 Create three tables:
    Jan 2023 jobs
    Feb 2023 jbos
    March 2023 jobs
 Foreshadowing: This will be used in another practise problem
> Use CREATE TABLE table_name AS syntax to create tables
> Look at a way to filter out only specific month (EXTRACT)
*/
CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date)=1;

CREATE TABLE february_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date)=2;

CREATE TABLE March_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date)=3;

ALTER TABLE March_jobs RENAME TO march_jobs;
-- -----------------------------------------
-- -----------------------------------------

/*CASE WHEN
Q: Want to categorize the salaries from each job posting. TO see if it fits in my salary range.
> Put salary into different buckets
> Degine what's a high, standard or low salary with own conditions
> Why? It is easy to determine which job postings are worth looking at based on salary.
> Checking only for Data Analyst roles
> Order from highest to lowest
*/
SELECT 
    job_title_short,
    salary_year_avg,
    CASE 
        WHEN salary_year_avg >= 150000 THEN 'High Salary'
        WHEN salary_year_avg BETWEEN 90000 AND 149999 THEN 'Standard Salary'
        WHEN salary_year_avg < 90000 THEN 'Low Salary'
        ELSE 'Salary Not Listed' -- Handles NULL values
    END AS salary_bucket
FROM 
    job_postings_fact
WHERE 
    job_title_short LIKE '%Data Analyst%' 
    AND salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC;


-- ----------
-- Subquery and QTE
-- ----------   
/*
Practice Problem Subquery
Identify the top 5 skills that are most frequently mentioned in job postings. 
Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table 
and then join this result with the skills_dim table to get the skill names.
*/
SELECT 
    skills_dim.skills, 
    skills_dim.type,
    top_skills.skill_count
    FROM (
SELECT skill_id,
    COUNT(skill_id) AS skill_count
FROM skills_job_dim
GROUP BY skill_id
ORDER BY skill_count DESC
LIMIT 5) AS top_skills
LEFT JOIN skills_dim ON skills_dim.skill_id=top_skills.skill_id
ORDER BY top_skills.skill_count DESC;
/*
Practice Problem 
Determine the size category ('Small', 'Medium', or 'Large') 
for each company by first identifying the number of job postings they have. 
Use a subquery to calculate the total job postings per company. 
A company is considered 'Small' if it has less than 10 job postings, 
'Medium' if the number of job postings is between 10 and 50, and 'Large' if it has more than 50 job postings. 
Implement a subquery to aggregate job counts per company before classifying them based on size.
*/
SELECT company_counts.company_id, company_counts.job_count,
CASE
    WHEN job_count<10 THEN 'Small'
    WHEN job_count BETWEEN 10 and 50 THEN 'Medium'
    ELSE 'Large'
END AS company_size    
FROM (
    SELECT jpf.company_id,
        COUNT(company_id) AS job_count
    FROM job_postings_fact AS jpf
    GROUP BY company_id) AS company_counts
LIMIT 5;

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

-- UNION PRACTICE
/*
- Get the corresponding skill and skill type for each job posting in q1
- Includes those without any sills, too
- Why? Look at the skills and the type for each job in the first quarter that has a salary> $70000
*/
SELECT 
    q1_jobs.job_id,
    q1_jobs.job_title,
    q1_jobs.salary_year_avg,
    skills_dim.skills AS skill_name,
    skills_dim.type AS skill_type
FROM (
    -- Combining all Q1 jobs into one result set
    SELECT * FROM january_jobs
    UNION ALL
    SELECT * FROM february_jobs
    UNION ALL
    SELECT * FROM march_jobs
) AS q1_jobs
-- Left join ensures we include jobs even if they have no skills listed
LEFT JOIN skills_job_dim ON q1_jobs.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    q1_jobs.salary_year_avg > 70000
ORDER BY 
    q1_jobs.salary_year_avg DESC;
-- HOW THE FUCK IT IS WORKING JUST WITH job_title?
-- Why the fuck it has both job title and job title short?


/* 
UNION PRACTISE 2
 find job postings from the q1 that have over $70K yearly salary
*/

SELECT 
    q1_jobs.job_id,
    q1_jobs.job_title_short,
    q1_jobs.job_location,
    q1_jobs.job_via,
    q1_jobs.job_posted_date::DATE,
    q1_jobs.salary_year_avg
    -- skills_dim.skills AS skill_name,
    -- skills_dim.type AS skill_type
FROM (
    -- Combining all Q1 jobs into one result set
    SELECT * FROM january_jobs
    UNION ALL
    SELECT * FROM february_jobs
    UNION ALL
    SELECT * FROM march_jobs
) AS q1_jobs
WHERE q1_jobs.salary_year_avg>70000
AND q1_jobs.job_title_short='Data Analyst'
ORDER BY
    q1_jobs.salary_year_avg DESC;