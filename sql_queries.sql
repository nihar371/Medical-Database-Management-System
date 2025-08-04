-- 1. List employees who joined in the last 2 years
SELECT * FROM Employee_P WHERE DOJ >= DATE('now', '-2 years');

-- 2. Find the average salary by city
SELECT City, AVG(Salary) AS Avg_Salary FROM Employee_P GROUP BY City;

-- 3. List all female employees older than 30
SELECT * FROM Employee_P WHERE Sex = 'F' AND Age > 30;

-- 4. Show top 5 highest paid employees
SELECT * FROM Employee_P ORDER BY Salary DESC LIMIT 5;

-- 5. Count number of employees in each pharmacy
SELECT PharID, COUNT(*) AS Total_Employees FROM Employee_P GROUP BY PharID;

-- 6. List employees with mobile numbers starting with '5557'
SELECT * FROM Employee_P WHERE Mobile LIKE '5557%';

-- 7. Show the youngest and oldest employee
SELECT * FROM Employee_P ORDER BY Age ASC LIMIT 1;
SELECT * FROM Employee_P ORDER BY Age DESC LIMIT 1;

-- 8. Show employee count by gender
SELECT Sex, COUNT(*) AS Count FROM Employee_P GROUP BY Sex;

-- 9. List cities with more than one employee
SELECT City, COUNT(*) AS Employee_Count FROM Employee_P GROUP BY City HAVING COUNT(*) > 1;

-- 10. Total salary paid across all employees
SELECT SUM(Salary) AS Total_Salary FROM Employee_P;

-- 11. Average age of employees per city
SELECT City, AVG(Age) AS Avg_Age FROM Employee_P GROUP BY City;

-- 12. List employees earning more than the city average
SELECT e.* FROM Employee_P e
JOIN (
  SELECT City, AVG(Salary) AS AvgSal FROM Employee_P GROUP BY City
) AS sub ON e.City = sub.City
WHERE e.Salary > sub.AvgSal;

-- 13. Number of employees who joined in each year
SELECT STRFTIME('%Y', DOJ) AS Year, COUNT(*) AS Count FROM Employee_P GROUP BY Year;

-- 14. List employees working in pharmacy with ID 5 and earning above 55,000
SELECT * FROM Employee_P WHERE PharID = 5 AND Salary > 55000;

-- 15. Find duplicate mobile numbers (if any)
SELECT Mobile, COUNT(*) FROM Employee_P GROUP BY Mobile HAVING COUNT(*) > 1;

-- 16. Show salary percentiles (50th, 75th)
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Salary) AS Median,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Salary) AS Percentile_75
FROM Employee_P;

-- 17. List employees with names starting and ending with same letter
SELECT * FROM Employee_P WHERE LOWER(SUBSTR(Name, 1, 1)) = LOWER(SUBSTR(Name, -1));

-- 18. Compare number of male vs female employees per city
SELECT City, Sex, COUNT(*) AS Count FROM Employee_P GROUP BY City, Sex;

-- 19. Show top 3 cities with highest average salary
SELECT City, AVG(Salary) AS AvgSalary FROM Employee_P GROUP BY City ORDER BY AvgSalary DESC LIMIT 3;

-- 20. Show employees who joined before age 25
SELECT *, (CAST((JULIANDAY(DOJ) - JULIANDAY(DATE('now', '-' || Age || ' years'))) AS INT)) AS JoinAge FROM Employee_P
WHERE JoinAge < 25;