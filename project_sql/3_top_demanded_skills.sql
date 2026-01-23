/*
- Finding the most in-demand skills for data scientist?
- just getting the top 5 in-demand skills for the job-postings
 */

-- WITH remote_job_skills AS(
--     SELECT
--         skill_id,
--         COUNT(*) AS skill_count
--      -- job_postings.job_work_from_home
--     FROM
--         skills_job_dim AS skills_to_job
--     INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id=skills_to_job.job_id
--     WHERE
--         job_postings.job_work_from_home= True
--         AND job_postings.job_title_short = 'Data Analyst'
--     GROUP BY
--         skill_id
-- )
-- SELECT skill.skill_id,
--     skill.skills AS skill_name,
--     skill_count
-- FROM remote_job_skills 
-- INNER JOIN skills_dim AS skill ON skill.skill_id=remote_job_skills.skill_id
-- ORDER BY skill_count DESC
-- LIMIT 5;


SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM  job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id=skills_dim.skill_id
WHERE
    job_title_short='Data Scientist'
    AND job_work_from_home=True
GROUP BY
    skills
ORDER BY
    demand_count DESC    
LIMIT 5;
