---Checking the information about your data
SELECT
    column_name,
    data_type,
    is_nullable,
    character_maximum_length
FROM
    information_schema.columns
WHERE
    table_name = 'student_performance';

---viewing the first 10 rows/entries
SELECT * FROM student_performance LIMIT 10;

-- columns
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'student_performance'
ORDER BY ordinal_position;

--checking for null columns
SELECT
    COUNT(*) - COUNT(Hours_Studied) AS Hours_Studied,
    COUNT(*) - COUNT(Attendance) AS Attendance,
    COUNT(*) - COUNT(Parental_Involvement) AS Parental_Involvement,
    COUNT(*) - COUNT(Access_to_Resources) AS Access_to_Resources,
    COUNT(*) - COUNT(Extracurricular_Activities) AS Extracurricular_Activities,
    COUNT(*) - COUNT(Sleep_Hours) AS Sleep_Hours,
    COUNT(*) - COUNT(Previous_Scores) AS Previous_Scores,
    COUNT(*) - COUNT(Motivation_Level) AS Motivation_Level,
    COUNT(*) - COUNT(Internet_Access) AS Internet_Access,
    COUNT(*) - COUNT(Tutoring_Sessions) AS Tutoring_Sessions,
    COUNT(*) - COUNT(Family_Income) AS Family_Income,
    COUNT(*) - COUNT(Teacher_Quality) AS Teacher_Quality,
    COUNT(*) - COUNT(School_Type) AS School_Type,
    COUNT(*) - COUNT(Peer_Influence) AS Peer_Influence,
    COUNT(*) - COUNT(Physical_Activity) AS Physical_Activity,
    COUNT(*) - COUNT(Learning_Disabilities) AS Learning_Disabilities,
    COUNT(*) - COUNT(Parental_Education_Level) AS Parental_Education_Level,
    COUNT(*) - COUNT(Distance_from_Home) AS Distance_from_Home,
    COUNT(*) - COUNT(Gender) AS Gender,
    COUNT(*) - COUNT(Exam_Score) AS Exam_Score
FROM student_performance;

--statistical summary
SELECT
    COUNT(Hours_Studied)  AS Hours_Studied_count,
    ROUND(AVG(Hours_Studied),2) AS  Hours_Studied_mean,
    ROUND(STDDEV(Hours_Studied), 2)         AS Hours_Studied_std,
    MIN(Hours_Studied)                      AS Hours_Studied_min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Hours_Studied) AS Hours_Studied_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Hours_Studied) AS Hours_Studied_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Hours_Studied) AS Hours_Studied_75,
    MAX(Hours_Studied)                      AS Hours_Studied_max,

    COUNT(Attendance)                       AS Attendance_count,
    ROUND(AVG(Attendance), 2)               AS Attendance_mean,
    ROUND(STDDEV(Attendance), 2)            AS Attendance_std,
    MIN(Attendance)                         AS Attendance_min,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Attendance) AS Attendance_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Attendance) AS Attendance_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Attendance) AS Attendance_75,
    MAX(Attendance)                         AS Attendance_max
FROM student_performance;

--checkimg for duplicates
SELECT COUNT(*) AS duplicated_count
FROM (
    SELECT Hours_Studied, Attendance, Parental_Involvement,
           Access_to_Resources, Extracurricular_Activities, Sleep_Hours,
           Previous_Scores, Motivation_Level, Internet_Access, Tutoring_Sessions,
           Family_Income, Teacher_Quality, School_Type, Peer_Influence,
           Physical_Activity, Learning_Disabilities, Parental_Education_Level,
           Distance_from_Home, Gender, Exam_Score,
           COUNT(*) AS cnt
    FROM student_performance
    GROUP BY Hours_Studied, Attendance, Parental_Involvement,
           Access_to_Resources, Extracurricular_Activities, Sleep_Hours,
           Previous_Scores, Motivation_Level, Internet_Access, Tutoring_Sessions,
           Family_Income, Teacher_Quality, School_Type, Peer_Influence,
           Physical_Activity, Learning_Disabilities, Parental_Education_Level,
           Distance_from_Home, Gender, Exam_Score
    HAVING COUNT(*) >1
     )
duplicates;

--Handling missing values
SELECT Parental_Education_Level, COUNT(*) AS count
FROM student_performance
GROUP BY Parental_Education_Level;

UPDATE  student_performance
SET Parental_Education_Level=(
    SELECT Parental_Education_Level
    FROM student_performance
    WHERE Parental_Education_Level IS NOT NULL
    GROUP BY Parental_Education_Level
    ORDER BY COUNT(*) DESC
    LIMIT 1
    )
WHERE Parental_Education_Level IS NULL;

SELECT Teacher_Quality, COUNT(*) AS count
FROM student_performance
GROUP BY Teacher_Quality;


SELECT Teacher_Quality,School_Type,COUNT(*) AS count
FROM student_performance
GROUP BY School_Type,Teacher_Quality;

DELETE FROM student_performance
WHERE Teacher_Quality IS NULL;
