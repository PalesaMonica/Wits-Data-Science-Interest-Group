---Creating the table

CREATE TABLE Attendance
(
    Student_ID VARCHAR(20),
    Date VARCHAR(20),
    Subject VARCHAR(20),
    Attendance_Status VARCHAR(20)

);

CREATE TABLE Performance
(
    Student_ID VARCHAR(20),
    Subject VARCHAR(20),
    Exam_Score INTEGER,
   Homework_Completion_Percentage VARCHAR(10),
   Teacher_Comments VARCHAR(100)

);

---joining the tables

CREATE TEMP TABLE att_perf_joined AS
SELECT
    att.Student_ID,
    att.Date,
    att.Subject AS att_Subject,
    att.Attendance_Status,
    perf.Subject AS perf_Subject,
    perf.Exam_Score,
    perf.Teacher_Comments,
    perf.Homework_Completion_Percentage
FROM Attendance AS att
INNER JOIN Performance AS perf
   ON att.Student_ID = perf.Student_ID;

--view first 5 entries of our data
SELECT * FROM att_perf_joined LIMIT 5;

SELECT COUNT(*) FROM att_perf_joined AS row_count;

SELECT COUNT(*) FROM information_schema.columns
     WHERE table_name = 'att_perf_joined';

---count rows and columns
--subquery
SELECT
    (SELECT COUNT(*) FROM att_perf_joined) AS row_count,
    (SELECT COUNT(*) FROM information_schema.columns
     WHERE table_name = 'att_perf_joined') AS col_count;

--cte
WITH table_shape AS (
    SELECT
    (SELECT COUNT(*) FROM att_perf_joined) AS row_count,
    (SELECT COUNT(*) FROM information_schema.columns
     WHERE table_name = 'att_perf_joined') AS col_count
    )
SELECT row_count,col_count
FROM  table_shape
;
---data cleaning
SELECT
    Homework_Completion_Percentage,
    COUNT(*) AS count
FROM att_perf_joined
GROUP BY Homework_Completion_Percentage
ORDER BY count DESC;

UPDATE att_perf_joined
SET Homework_Completion_Percentage=TRIM(TRAILING '%' FROM Homework_Completion_Percentage )
WHERE Homework_Completion_Percentage LIKE '100%' OR  Homework_Completion_Percentage LIKE '80%';

--CONVERT TO NUMERIC
ALTER TABLE att_perf_joined
ALTER COLUMN Homework_Completion_Percentage TYPE NUMERIC
USING Homework_Completion_Percentage::NUMERIC;

UPDATE att_perf_joined
SET Homework_Completion_Percentage=0
WHERE Homework_Completion_Percentage =-5;

SELECT DISTINCT Homework_Completion_Percentage
FROM att_perf_joined;

--Data Standardization
SELECT DISTINCT Attendance_Status
FROM att_perf_joined;

UPDATE att_perf_joined
SET Attendance_Status=LOWER(Attendance_Status);

UPDATE att_perf_joined
SET Attendance_Status=TRIM(Attendance_Status);

UPDATE att_perf_joined
SET Attendance_Status='absent'
WHERE Attendance_Status LIKE 'abs%';


SELECT
    Teacher_Comments,
    COUNT(*) AS count
FROM att_perf_joined
GROUP BY Teacher_Comments
ORDER BY count DESC;

ALTER TABLE att_perf_joined
DROP COLUMN Teacher_Comments;

SELECT column_name
FROM
    information_schema.columns
WHERE
    table_name = 'att_perf_joined';

ALTER TABLE att_perf_joined
DROP COLUMN "date";

ALTER TABLE att_perf_joined
RENAME COLUMN att_subject TO First_Subject;

ALTER TABLE att_perf_joined
RENAME COLUMN perf_subject TO Second_Subject;

--Duplicates
SELECT *,
ROW_NUMBER() OVER (PARTITION BY Student_ID,First_Subject,Second_Subject,Exam_Score,Homework_Completion_Percentage,Attendance_Status) AS row_num
FROM att_perf_joined;

WITH duplicates_cte AS (
    SELECT ctid,
           ROW_NUMBER() OVER (
               PARTITION BY
                   Student_ID,
                   First_Subject,
                   Second_Subject,
                   Exam_Score,
                   Homework_Completion_Percentage,
                   Attendance_Status
               ORDER BY ctid
           ) AS row_num
    FROM att_perf_joined
)
DELETE FROM att_perf_joined
WHERE ctid IN (
    SELECT ctid
    FROM duplicates_cte
    WHERE row_num > 1
);


--statistical summary
SELECT
    COUNT(Exam_Score) as Exam_Score_Count,
    ROUND(AVG(Exam_Score),2) AS Exam_Score_Mean,
    ROUND(STDDEV(Exam_Score),2) AS Exam_Score_Std,
    MIN(Exam_Score)  AS Exam_Score_Min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Exam_Score) AS Exam_Score_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Exam_Score) AS Exam_Score_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Exam_Score) AS Exam_Score_75,
    MAX(Exam_Score) AS Exam_Score_Max,

    COUNT(Homework_Completion_Percentage) as Homework_Completion_Percentage_Count,
    ROUND(AVG(Homework_Completion_Percentage),2) AS Homework_Completion_Percentage_Mean,
    ROUND(STDDEV(Homework_Completion_Percentage),2) AS Homework_Completion_Percentage_Std,
    MIN(Homework_Completion_Percentage)  AS Homework_Completion_Percentage_Min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Homework_Completion_Percentage) AS Homework_Completion_Percentage_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Homework_Completion_Percentage) AS Homework_Completion_Percentage_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Homework_Completion_Percentage) AS Homework_Completion_Percentage_75,
    MAX(Homework_Completion_Percentage) AS Homework_Completion_Percentage_Max
FROM att_perf_joined;

SELECT
    Exam_Score,
    COUNT(*) AS count
FROM att_perf_joined
WHERE Exam_Score >100
GROUP BY Exam_Score
ORDER BY count DESC;

UPDATE att_perf_joined
    SET Exam_Score=100
WHERE Exam_Score>100;

SELECT
  MAX(Exam_Score) AS Exam_Score_Max
FROM att_perf_joined;

With stats AS
    (
        SELECT
            AVG(Exam_Score) AS mean_exam_score,
            STDDEV(Exam_Score) AS std_exam_score,
            AVG(Homework_Completion_Percentage) AS mean_hwp,
            STDDEV(Homework_Completion_Percentage) AS std_hmp,
            COUNT(*) AS total
        FROM att_perf_joined
    )
SELECT
    (SUM((Exam_Score-stats.mean_exam_score)^4)/(stats.total*stats.std_exam_score^4))-3 AS kurt_exam_score,
    (SUM((Homework_Completion_Percentage-stats.mean_hwp)^4)/(stats.total*stats.std_hmp^4))-3 AS kurt_homework_per
FROM  att_perf_joined,stats
GROUP BY stats.total,stats.std_exam_score,stats.std_hmp;
DROP TABLE IF EXISTS att_perf_joined;



---What is each student mark compared to the overall class average?
SELECT
    Exam_Score,
    AVG(Exam_Score) OVER() AS average_exam_score
FROM  att_perf_joined;

SELECT
    Homework_Completion_Percentage,
    Second_Subject,
    AVG(Homework_Completion_Percentage) OVER(PARTITION BY Second_Subject) AS  avg_score
FROM att_perf_joined;

SELECT COUNT(*) AS count,
       Second_Subject
FROM att_perf_joined
GROUP BY Second_Subject;
