--Load the data into a SQL database table.
--Check the data
SELECT 'employee' , COUNT(*)  FROM Employee;
SELECT 'education', COUNT(*) FROM EducationLevel;
SELECT 'satisfied', COUNT(*) FROM SatisfiedLevel;
SELECT 'performance', COUNT(*) FROM PerformanceRating;
SELECT 'rate', COUNT(*) FROM RatingLevel ;
--Explore Data 
SELECT * FROM Employee LIMIT 10; 
SELECT * FROM EducationLevel;

--Data Cleaning- Capitalization
UPDATE Employee SET Department = TRIM(Department);
UPDATE Employee SET Department = UPPER(SUBSTR(Department,1,1));
UPDATE Employee SET firstname = UPPER(firstname), lastname = UPPER(lastname);

--Missing Values and NULL
UPDATE Employee SET Salary = NULL WHERE Salary = '';
SELECT 
    SUM(CASE WHEN TRIM(COALESCE(FirstName,'')) = '' THEN 1 ELSE 0 END) AS missing_FirstName,
    SUM(CASE WHEN TRIM(COALESCE(LastName,'')) = '' THEN 1 ELSE 0 END) AS missing_LastName,
    SUM(CASE WHEN TRIM(COALESCE(Gender,'')) = '' THEN 1 ELSE 0 END) AS missing_Gender,
    SUM(CASE WHEN TRIM(COALESCE(Department,'')) = '' THEN 1 ELSE 0 END) AS missing_Department,
    SUM(CASE WHEN Salary IS NULL THEN 1 ELSE 0 END) AS missing_Salary,
    SUM(CASE WHEN Education IS NULL THEN 1 ELSE 0 END) AS missing_Education,
    SUM(CASE WHEN TRIM(COALESCE(Attrition,'')) = '' THEN 1 ELSE 0 END) AS missing_Attrition
From Employee;
SELECT
    COUNT(EmployeeID) AS employee_id_count,
    COUNT(COALESCE(FirstName,'')) AS first_name_count,
    COUNT(COALESCE(LastName,'')) AS last_name_count,
    COUNT(COALESCE(Gender,'')) AS gender_count,
    COUNT(COALESCE(Age,0)) AS age_count,
    COUNT(COALESCE(BusinessTravel,'')) AS business_travel_count,
    COUNT(COALESCE(Department,'')) AS department_count,
    COUNT(COALESCE(DistanceFromHome_km,0)) AS distance_from_home_km_count,
    COUNT(COALESCE(State,'')) AS state_count,
    COUNT(COALESCE(Ethnicity,'')) AS ethnicity_count,
    COUNT(COALESCE(Education,'')) AS education_count,
    COUNT(COALESCE(EducationField,'')) AS education_field_count,
    COUNT(COALESCE(JobRole,'')) AS job_role_count,
    COUNT(COALESCE(MaritalStatus,'')) AS marital_status_count,
    COUNT(COALESCE(Salary,0)) AS salary_count,
    COUNT(COALESCE(StockOptionLevel,0)) AS stock_option_level_count,
    COUNT(COALESCE(OverTime,'')) AS over_time_count,
    COUNT(COALESCE(HireDate,'')) AS hire_date_count,
    COUNT(COALESCE(Attrition,'')) AS attrition_count,
    COUNT(COALESCE(YearsAtCompany,0)) AS years_at_company_count,
    COUNT(COALESCE(YearsInMostRecentRole,0)) AS years_in_most_recent_role_count,
    COUNT(COALESCE(YearsSinceLastPromotion,0)) AS years_since_last_promotion_count,
    COUNT(COALESCE(YearsWithCurrManager,0)) AS years_with_curr_manager_count
FROM Employee;
SELECT e.EmployeeID
FROM Employee AS e
LEFT JOIN EducationLevel AS ed
  ON e.Education = ed.EducationLevelID
WHERE ed.EducationLevelID IS NULL;

SELECT p.EmployeeID FROM PerformanceRating AS p
 LEFT JOIN Employee AS e ON p.EmployeeID = e.EmployeeID 
WHERE e.EmployeeID IS NULL;
SELECT 
    e.EmployeeID, 
    e.Gender, 
    e.Department, 
    e.Salary, 
    ed.EducationLevel, 
    p.PerformanceID, 
    p.JobSatisfaction, 
    p.TrainingOpportunitiesWithinYear, 
    p.TrainingOpportunitiesTaken, 
    p.WorkLifeBalance
FROM employee AS e
LEFT JOIN EducationLevel AS ed 
    ON e.Education = ed.EducationLevelID
LEFT JOIN performancerating AS p 
    ON e.EmployeeID = p.EmployeeID;

--Outliers
SELECT COUNT(*) FROM Employee WHERE Age < 0;
SELECT COUNT(*) FROM Employee WHERE Salary < 0; 
SELECT EmployeeID, Age FROM Employee WHERE Age < 18 OR Age > 60;
SELECT COUNT(*) AS InvalidRatings
FROM PerformanceRating
WHERE 
    SelfRating NOT BETWEEN 1 AND 5
    OR ManagerRating NOT BETWEEN 1 AND 5
    OR EnvironmentSatisfaction NOT BETWEEN 1 AND 5
    OR JobSatisfaction NOT BETWEEN 1 AND 5
    OR RelationshipSatisfaction NOT BETWEEN 1 AND 5
    OR WorkLifeBalance NOT BETWEEN 1 AND 5;

--Remove duplicate 
SELECT
 EmployeeID, COUNT(*) AS cnt FROM Employee
 GROUP BY EmployeeID HAVING COUNT(*) > 1;

SELECT performanceid, COUNT(*) FROM PerformanceRating
 GROUP BY performanceid HAVING COUNT(*) > 1;



--Performance & Satisfaction Analysis


--Create integration table 
CREATE TABLE Full_Employee_Data AS
SELECT
  e.EmployeeID,
  e.Gender,
  e.Department,
  e.Salary,
  e.Age,
  e.YearsAtCompany,
  e.OverTime,
  e.Attrition,
  ed.EducationLevel,
  p.PerformanceID,
  p.ManagerRating,
  p.SelfRating,
  p.EnvironmentSatisfaction,
  p.JobSatisfaction,
  p.RelationshipSatisfaction,
  p.WorkLifeBalance,
  p.TrainingOpportunitiesWithinYear,
  p.TrainingOpportunitiesTaken
FROM Employee e
LEFT JOIN EducationLevel ed
  ON e.Education = ed.EducationLevelID
LEFT JOIN PerformanceRating p
  ON e.EmployeeID = p.EmployeeID;

--Descriptive analysis 
SELECT 
    ed.EducationLevel,
   COUNT(e.EmployeeID) AS employees
FROM Employee e
LEFT JOIN EducationLevel ed
  ON e.Education = ed.EducationLevelID
GROUP BY ed.EducationLevel
ORDER BY employees DESC;

SELECT 
    ed.EducationLevel,
    COUNT(e.EmployeeID) AS cnt,
    ROUND(AVG(COALESCE(e.Salary,0)), 2) AS avg_salary,
    ROUND(AVG(COALESCE(e.YearsAtCompany,0)), 2) AS avg_years_at_company
FROM Employee e
LEFT JOIN EducationLevel ed
  ON e.Education = ed.EducationLevelID
GROUP BY ed.EducationLevel
ORDER BY avg_salary DESC;

SELECT MIN(Salary) AS MinSalary, MAX(Salary) AS MaxSalary, 
AVG(Salary) AS AvgSalary FROM Employee; 

SELECT MIN(Age) AS MinAge, MAX(Age) AS MaxAge, AVG(Age) 
AS AvgAge FROM Employee;

--Performance & Satisfaction Analysis
SELECT 
    Department,
    ROUND(AVG(JobSatisfaction), 2) AS Avg_Job_Satisfaction,
    ROUND(AVG(EnvironmentSatisfaction), 2) AS Avg_Environment_Satisfaction,
    ROUND(AVG(TrainingOpportunitiesWithinYear), 2) AS Avg_Training_Within_Year,
    ROUND(AVG(WorkLifeBalance), 2) AS Avg_Work_Life_Balance
FROM performancerating p
JOIN employee e ON p.EmployeeID = e.EmployeeID
GROUP BY Department;

--The relationship between Job Satisfaction ,Work Life Balance, Salary, Overtime and Training Opportunities:
--Average Job Satisfaction depend on Work Life Balance
SELECT WorkLifeBalance,
       AVG(JobSatisfaction) AS Avg_JobSatisfaction,
       AVG(SelfRating) AS Avg_SelfRating,
       AVG(ManagerRating) AS Avg_ManagerRating
FROM PerformanceRating p
JOIN Employee e ON p.EmployeeID = e.EmployeeID
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;

--Average Job Satisfaction depend on salary 
SELECT 
    CASE 
        WHEN Salary < 5000 THEN '<5000'
        WHEN Salary BETWEEN 5000 AND 10000 THEN '5000-10000'
        WHEN Salary BETWEEN 10001 AND 15000 THEN '10001-15000'
        ELSE '>15000'
    END AS Salary_Range,
    AVG(JobSatisfaction) AS Avg_JobSatisfaction,
    AVG(SelfRating) AS Avg_SelfRating,
    AVG(ManagerRating) AS Avg_ManagerRating
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
GROUP BY Salary_Range
ORDER BY Salary_Range;

--Average Job Satisfaction depend on overtime
SELECT OverTime,
       AVG(JobSatisfaction) AS Avg_JobSatisfaction,
       AVG(SelfRating) AS Avg_SelfRating,
       AVG(ManagerRating) AS Avg_ManagerRating
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
GROUP BY OverTime; 


--Average Job Satisfaction depend on job opportunities 
SELECT 
    ROUND(AVG(COALESCE(p.TrainingOpportunitiesWithinYear,0)), 0) AS Avg_TrainingWithinYear,
    ROUND(AVG(COALESCE(p.JobSatisfaction,0)),2) AS Avg_JobSatisfaction,
    ROUND(AVG(COALESCE(p.SelfRating,0)),2) AS Avg_SelfRating,
    ROUND(AVG(COALESCE(p.ManagerRating,0)),2) AS Avg_ManagerRating
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
GROUP BY p.TrainingOpportunitiesWithinYear
ORDER BY Avg_TrainingWithinYear;

--Correlation 
--Performance analysis and left depend on Salary / Age / Years At Company.
--Employee performance depends on Age
WITH perf AS (

    SELECT 

        EmployeeID,

        AVG(JobSatisfaction) AS Avg_JobSatisfaction,

        AVG(SelfRating) AS Avg_SelfRating,

        AVG(ManagerRating) AS Avg_ManagerRating

    FROM PerformanceRating

    GROUP BY EmployeeID

)
 
SELECT 

    CASE 

        WHEN e.Age < 25 THEN '<25'

        WHEN e.Age BETWEEN 25 AND 35 THEN '25-35'

        WHEN e.Age BETWEEN 36 AND 45 THEN '36-45'

        ELSE '>45'

    END AS Age_Range,
 
    AVG(p.Avg_JobSatisfaction) AS Avg_JobSatisfaction,

    ROUND(AVG(p.Avg_SelfRating),2) AS Avg_SelfRating,

    ROUND(AVG(p.Avg_ManagerRating),2) AS Avg_ManagerRating,
 
    COUNT(*) AS Employee_Count
 
FROM Employee e

LEFT JOIN perf p

    ON e.EmployeeID = p.EmployeeID
 
GROUP BY Age_Range

ORDER BY Age_Range;
 

--Employee performance depends on Years At Company
SELECT 
    CASE 
        WHEN YearsAtCompany < 2 THEN '<2'
        WHEN YearsAtCompany BETWEEN 2 AND 5 THEN '2-5'
        WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6-10'
        ELSE '>10'
    END AS YearsAtCompany_Range,
    AVG(JobSatisfaction) AS Avg_JobSatisfaction,
    AVG(SelfRating) AS Avg_SelfRating,
    AVG(ManagerRating) AS Avg_ManagerRating,
    COUNT(DISTINCT e.employeeid) AS Employee_Count
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
GROUP BY YearsAtCompany_Range
ORDER BY YearsAtCompany_Range;



--Salary analysis 
SELECT 
    e.Department, 
    el.EducationLevel, 
    ROUND(AVG(e.Salary), 2) AS Avg_Salary, 
    ROUND(AVG(p.ManagerRating), 2) AS Avg_ManagerRating,
    ROUND(AVG(p.SelfRating), 2) AS Avg_SelfRating
FROM Employee e
JOIN EducationLevel el 
    ON e.Education = el.EducationLevelID
JOIN PerformanceRating p 
    ON e.EmployeeID = p.EmployeeID
GROUP BY e.Department, el.EducationLevel;

--Percentage of attrition depends on salary range
SELECT 
    CASE 
        WHEN Salary < 5000 THEN '<5000'
        WHEN Salary BETWEEN 5000 AND 10000 THEN '5000-10000'
        WHEN Salary BETWEEN 10001 AND 15000 THEN '10001-15000'
        ELSE '>15000'
    END AS Salary_Range,
    COUNT(CASE WHEN Attrition='Yes' THEN 1 END)*100.0/COUNT(*) AS Attrition_Percentage
FROM Employee
GROUP BY Salary_Range
ORDER BY Salary_Range;

--The impact of Over Time + Training on performance and Department + Attrition on Job Satisfaction: 
--The impact of Over Time + Training on performance
SELECT 
    OverTime,
    CASE 
        WHEN TrainingOpportunitiesWithinYear < 2 THEN '<2'
        WHEN TrainingOpportunitiesWithinYear BETWEEN 2 AND 4 THEN '2-4'
        ELSE '>=5'
    END AS Training_Group,
    AVG(JobSatisfaction) AS Avg_JobSatisfaction,
    AVG(SelfRating) AS Avg_SelfRating,
    AVG(ManagerRating) AS Avg_ManagerRating,
    COUNT(DISTINCT e.EmployeeID) AS Employee_Count
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
GROUP BY OverTime, Training_Group
ORDER BY OverTime, Training_Group;

--The impact of Department + Attrition on Job Satisfaction
SELECT 
    Department,
    Attrition,
    AVG(JobSatisfaction) AS Avg_JobSatisfaction,
    AVG(SelfRating) AS Avg_SelfRating,
    AVG(ManagerRating) AS Avg_ManagerRating,
    COUNT(DISTINCT e.EmployeeID) AS Employee_Count
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
GROUP BY Department, Attrition
ORDER BY Department, Attrition;

-- Determine the impact of overtime on work-life balance and performance
SELECT 
    e.OverTime,
    COUNT(DISTINCT e.EmployeeID) AS Employee_Count,
    AVG(p.WorkLifeBalance) AS Avg_WorkLifeBalance,
    AVG(p.JobSatisfaction) AS Avg_Job_Satisfaction,
    AVG(p.SelfRating) AS Avg_SelfRating,
    AVG(p.ManagerRating) AS Avg_ManagerRating
FROM Employee AS e
LEFT JOIN PerformanceRating AS p
    ON e.EmployeeID = p.EmployeeID
GROUP BY e.OverTime
ORDER BY Avg_WorkLifeBalance ASC;


--Performance and Training 

SELECT 
    SelfRating,
    ROUND(AVG(TrainingOpportunitiesWithinYear), 2) AS Avg_Training_Within_Year,
    ROUND(AVG(TrainingOpportunitiesTaken), 2) AS Avg_Training_Taken
FROM performancerating
GROUP BY SelfRating
ORDER BY SelfRating;  


--Dashboard Query
SELECT 
    e.EmployeeID, 
    e.Gender, 
    e.Department, 
    e.Salary, 
    el.EducationLevel, 
    p.JobSatisfaction, 
    p.TrainingOpportunitiesWithinYear, 
    p.TrainingOpportunitiesTaken,
    p.ManagerRating,
    p.SelfRating
FROM Employee e
JOIN EducationLevel el 
    ON e.Education = el.EducationLevelID
JOIN PerformanceRating p 
    ON e.EmployeeID = p.EmployeeID;
--Question 1:
--What are the factors most associated with a decrease in employee satisfaction at work (Attrition)?
--Objective: Identify the main reasons behind reduced job satisfaction leading to higher attrition rates.
--Analysis:
--Join the Employee table with the Performance table using EmployeeID.
--Analyze the relationship between Attrition and factors such as JobSatisfaction, EnvironmentSatisfaction, WorkLifeBalance, and Department.
--Practical Insight: Identify departments and conditions where satisfaction is low so management can improve the work environment and training system.
SELECT
Department,
    ROUND(AVG(JobSatisfaction),2) AS Avg_Job_Satisfaction,
    ROUND(AVG(EnvironmentSatisfaction),2) AS Avg_Env_Satisfaction,
    ROUND(AVG(RelationshipSatisfaction),2) AS Avg_Relationship_Satisfaction,
    ROUND(AVG(WorkLifeBalance),2) AS Avg_WorkLifeBalance
FROM Full_Employee_Data
GROUP BY Department
ORDER BY Avg_Job_Satisfaction ASC;


--Question 2:
--Does overtime (Over Time) affect work–life balance and employee performance?
--Objective: Evaluate how working overtime impacts work–life balance and overall performance.
--Analysis:
--Analyze the relationship between Over Time, Work Life Balance, and ManagerRating from the Performance table joined with the Employee table.
--Practical Insight: Identify if employees who frequently work overtime tend to have lower satisfaction or performance, helping management reconsider working hours and workload distribution.
SELECT 
    e.OverTime,
    COUNT(DISTINCT e.EmployeeID) AS Num_Employees,
    ROUND(AVG(p.WorkLifeBalance), 2) AS Avg_WorkLifeBalance,
    ROUND(AVG(p.ManagerRating), 2) AS Avg_ManagerRating,
    ROUND(AVG(p.SelfRating), 2) AS Avg_SelfRating
FROM Employee e
LEFT JOIN PerformanceRating p
    ON e.EmployeeID = p.EmployeeID
GROUP BY e.OverTime
ORDER BY Avg_WorkLifeBalance ASC;


--Question 3:
--What is the relationship between salary (Salary) and performance level (ManagerRating, SelfRating)?
--Objective: Determine whether higher salaries are associated with better performance or higher job satisfaction.
--Analysis:
--Study the relationship between Salary, ManagerRating, and JobSatisfaction.
--Practical Insight: Help management understand whether salary differences reflect performance or satisfaction rather than just years of service.
SELECT 
    Department,
    ROUND(AVG(Salary),2) AS Avg_Salary,
    ROUND(AVG(ManagerRating),2) AS Avg_ManagerRating,
    ROUND(AVG(SelfRating),2) AS Avg_SelfRating
FROM Full_Employee_Data
GROUP BY Department
ORDER BY Avg_Salary DESC;


SELECT 
    CASE
        WHEN Salary < 80000 THEN '< 80k'
        WHEN Salary BETWEEN 80000 AND 120000 THEN '80k–120k'
        WHEN Salary BETWEEN 120001 AND 180000 THEN '120k–180k'
        WHEN Salary BETWEEN 180001 AND 300000 THEN '180k–300k'
        ELSE '> 300k'
    END AS Salary_Band,
    COUNT(*) AS Employee_Count
FROM Employee
GROUP BY Salary_Band
ORDER BY Employee_Count DESC;


--Question 4:
--Do training opportunities affect promotion rates?
--Objective: Study the impact of training on employee growth within the company.
--Analysis:
--Use Training OpportunitiesWithinYear, TrainingOpportunitiesTaken, and YearsSinceLastPromotion from the Performance table.
--Practical Insight: Identify whether employees who take more training get promoted faster and perform better.
-- Adding new columns to Full_Employee_Data table. 
ALTER TABLE Full_Employee_Data ADD COLUMN HireDate TEXT;
ALTER TABLE Full_Employee_Data ADD COLUMN LastPromotionDate TEXT;
ALTER TABLE Full_Employee_Data ADD COLUMN YearsSinceLastPromotion REAL;

--Practical Insight: Identify whether employees who take more training get promoted faster and perform better.
UPDATE Full_Employee_Data
SET 
  HireDate = (SELECT HireDate FROM Employee e WHERE e.EmployeeID = Full_Employee_Data.EmployeeID),
  LastPromotionDate = (SELECT LastPromotionDate FROM Employee e WHERE e.EmployeeID 
   = Full_Employee_Data.EmployeeID),
  YearsSinceLastPromotion = ROUND(
      (julianday('now') - julianday(
 (SELECT LastPromotionDate FROM Employee e WHERE e.EmployeeID = Full_Employee_Data.EmployeeID)
      )) / 365.0, 2);
     
 
UPDATE Full_Employee_Data
SET YearsSinceLastPromotion = 
    ROUND(
        (julianday('now') - julianday(LastPromotionDate)) / 365.0, 2
    )
WHERE LastPromotionDate IS NOT NULL;

UPDATE Full_Employee_Data
SET YearsSinceLastPromotion = 0
WHERE LastPromotionDate IS NULL;

SELECT 
  TrainingOpportunitiesTaken,
  AVG((SelfRating + ManagerRating) / 2.0) AS AvgPerformance,
  AVG((JobSatisfaction + EnvironmentSatisfaction + RelationshipSatisfaction) / 3.0) AS AvgOverallSatisfaction
FROM PerformanceRating
GROUP BY TrainingOpportunitiesTaken
ORDER BY TrainingOpportunitiesTaken;

SELECT 
    Department,
    ROUND(AVG(TrainingOpportunitiesWithinYear),2) AS Avg_Training_Opportunities_WithinYear,
    ROUND(AVG(TrainingOpportunitiesTaken),2) AS Avg_Training_Opportunities_Taken,
    ROUND(AVG(ManagerRating),2) AS Avg_ManagerRating,
    ROUND(AVG(SelfRating),2) AS Avg_SelfRating,
    ROUND(AVG(YearsAtCompany),2) AS Avg_YearsAtCompany
FROM Full_Employee_Data
GROUP BY Department
ORDER BY Avg_Training_Opportunities_Taken DESC;

SELECT 
    CASE 
        WHEN p.TrainingOpportunitiesWithinYear > 0 THEN 'Received Training'
        ELSE 'No Training'
    END AS TrainingStatus,

    COUNT(DISTINCT e.EmployeeID) AS Num_Employees,
    ROUND(AVG(p.ManagerRating), 2) AS Avg_ManagerRating,
    ROUND(AVG(p.SelfRating), 2) AS Avg_SelfRating,
    ROUND(AVG(e.YearsAtCompany), 2) AS Avg_YearsAtCompany
FROM Employee e
LEFT JOIN PerformanceRating p 
    ON e.EmployeeID = p.EmployeeID
GROUP BY TrainingStatus
ORDER BY Avg_ManagerRating DESC;







SELECT 
    Department,
    ROUND(AVG(TrainingOpportunitiesWithinYear),2) AS Avg_Training_Opportunities_WithinYear,
    ROUND(AVG(TrainingOpportunitiesTaken),2) AS Avg_Training_Opportunities_Taken,
    ROUND(AVG(ManagerRating),2) AS Avg_ManagerRating,
    ROUND(AVG(SelfRating),2) AS Avg_SelfRating,
    ROUND(AVG(YearsAtCompany),2) AS Avg_YearsAtCompany,
    ROUND(AVG((ManagerRating + SelfRating) / 2.0),2) AS PromotionPotentialIndex
FROM Full_Employee_Data
GROUP BY Department
ORDER BY Avg_Training_Opportunities_Taken DESC;

--Question 5:
--What are the common characteristics among employees who left the company (Attrition = Yes)?
--Objective: Develop a prediction model to identify employees likely to leave in the future.
--Analysis:
--Analyze Attrition against factors such as Age, Department, OverTime, Salary, JobSatisfaction, and YearsAtCompany.
--Practical Insight: Management can detect at-risk employees early and take proactive steps to improve retention (e.g., task redistribution or engagement programs).
SELECT 
  UPPER(TRIM(e.Department)) AS Department,
  ROUND(AVG(e.Age), 2) AS Avg_Age,
  ROUND(AVG(e.Salary), 2) AS Avg_Salary,
  ROUND(AVG(e.YearsAtCompany), 2) AS Avg_YearsAtCompany,
  ROUND(AVG(p.JobSatisfaction), 2) AS Avg_JobSatisfaction,
  ROUND(AVG(p.ManagerRating), 2) AS Avg_ManagerRating,
  ROUND(AVG(p.WorkLifeBalance), 2) AS Avg_WorkLifeBalance,
  ROUND(AVG(p.EnvironmentSatisfaction), 2) AS Avg_EnvironmentSatisfaction,
  ROUND(AVG(p.RelationshipSatisfaction), 2) AS Avg_RelationshipSatisfaction, 
  COUNT(DISTINCT e.EmployeeID) AS Attrition_Count,
  ROUND(100.0 * COUNT(DISTINCT e.EmployeeID) /
    (SELECT COUNT(DISTINCT EmployeeID) FROM Employee WHERE LOWER(TRIM(Attrition)) = 'yes'), 2) AS Attrition_Percentage
FROM Employee e
LEFT JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
WHERE LOWER(TRIM(e.Attrition)) = 'yes'
GROUP BY e.Department
ORDER BY Attrition_Count DESC;
