CREATE TABLE job_applied(
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
);

SELECT * FROM job_applied;

INSERT INTO job_applied(s
  job_id,
    application_sent_date,
    custom_resume,
    resume_file_name,
    cover_letter_sent ,
    cover_letter_file_name ,
    status 
)
VALUES(
    1,
    '2025-03-01',
    true,
    'resume_01.pdf',
    true,
    'cover_letter_01.pdf',
    'submitted'
),
(2, '2025-03-05', true, 'cv_smith_final.pdf', false, NULL, 'pending'),
(3, '2025-03-12', false, NULL, false, NULL, 'draft'),
(4, '2025-03-15', true, 'portfolio_v2.pdf', true, 'cl_v2.pdf', 'submitted'),
(5, '2025-03-18', true, 'resume_marketing.pdf', false, NULL, 'reviewing'),
(6, '2025-03-22', true, 'dev_resume_2025.pdf', true, 'cover_letter_dev.pdf', 'submitted'),
(7, '2025-03-25', false, NULL, true, 'generic_cl.pdf', 'action_required'),
(8, '2025-04-02', true, 'john_doe_resume.pdf', false, NULL, 'submitted'),
(9, '2025-04-10', true, 'senior_role_cv.pdf', true, 'exec_summary.pdf', 'interview_scheduled'),
(10, '2025-04-14', false, 'draft_resume.docx', false, NULL, 'withdrawn');

-- ALTER TABLE: Adding a new Column : ADD
ALTER TABLE job_applied ADD contact VARCHAR(50);

-- Updating
UPDATE job_applied SET contact='Timothee Newman' WHERE job_id=1;
--all 10 fields has input in contact(just deleted the code to look more clean)

-- ALTER TABLE: Renaming Column : RENAME
ALTER TABLE job_applied RENAME contact TO contact_name;

-- ALTER TABLE: Changing Column: (ALTER COLUMN column_name TYPE datatype) 
ALTER TABLE job_applied 
ALTER COLUMN contact_name TYPE TEXT;


--ALTER COLUMN : for deleting whole columns; 
-- AT first Im adding a dummy column to be deleted
ALTER TABLE job_applied ADD delete_this_column VARCHAR(255);
--Deleting: ALTER TABLE table_name DROP COLUMN column_name
ALTER TABLE job_applied DROP COLUMN delete_this_column;

-- DROP TABLE
-- ADDING DUMMY TABLE
CREATE TABLE jdelete_table(
    haha_id INT,
    some_date DATE,
    some_name VARCHAR(255),
    status VARCHAR(50)
);
--DROP TABLE table_name
DROP TABLE jdelete_table;