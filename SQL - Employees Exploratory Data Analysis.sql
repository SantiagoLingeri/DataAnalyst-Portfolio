							
                            /*		SQL - Employees Exploratory Data Analysis (EDA)		*/


-- This project involves conducting an Exploratory Data Analysis (EDA) of the previos cleaned Employees Database, in order to identify patterns in data and answer relevant HR questions. 

-- By leveraging SQL queries, the project aims to provide valuable insights into the company's workforce composition, gender distribution, understand compensation, positions, departments, and explore various aspects of the employee dataset.

-- Finally, the insights and conclutions are summarized with tables and stored procedures to automate everyday proccesses and make Data Exploration more dynamic in the future.

-- SQL skills used: Data Manipulation Language(DML), Select, setting conditions, Joins, Aggregate Functions, Converting Data Types, Subqueries, Creating Views, Stored Routines.

-------------------------------------------------------------------------------------------------------------------------

/*		Working with relational Database		*/

USE employees;

-------------------------------------------------------------------------------------------------------------------------

/*		Overview of data tables		*/

SELECT *
FROM departments
ORDER BY dept_no;

SELECT *
FROM titles
ORDER BY 1;

SELECT *
FROM employees
ORDER BY emp_no;

SELECT *
FROM salaries
ORDER BY 1;

SELECT *
FROM dept_emp
ORDER BY 1;

SELECT *
FROM dept_manager
ORDER BY 1;

-------------------------------------------------------------------------------------------------------------------------

/*		Total employees		*/

SELECT DISTINCT
	COUNT(emp_no) AS total_emp
FROM employees;

-------------------------------------------------------------------------------------------------------------------------

/*		Total employees by department		*/

SELECT
	d.dept_no AS dept_no,
	d.dept_name AS department,
    COUNT(de.emp_no) AS total_emp,
    ROUND(COUNT(de.emp_no) / (SELECT COUNT(*) FROM dept_emp) * 100,0) AS '%_of_total'
FROM
	dept_emp de
		JOIN
	departments d ON de.dept_no = d.dept_no
GROUP BY
	1
ORDER BY
	3 DESC;

-------------------------------------------------------------------------------------------------------------------------

/*		Total spent on salaries (in billions)		*/

SELECT ROUND(SUM(salary) / 1000000000,2) AS total_salaries_in_billions
FROM salaries;

-------------------------------------------------------------------------------------------------------------------------

/*		Total spent on salaries by department (in billions)	*/

SELECT 
	d.dept_no AS dept_no,
	d.dept_name,
	ROUND(SUM(s.salary) / 1000000000,2) AS total_salaries_in_billions
FROM 
	salaries s
		JOIN
	dept_emp de ON s.emp_no = de.emp_no
		JOIN
	departments d ON de.dept_no = d.dept_no
GROUP BY 
	d.dept_name
ORDER BY 
	total_salaries_in_billions DESC;

-------------------------------------------------------------------------------------------------------------------------

/*		AVG salary by department		*/

SELECT
	d.dept_no AS dept_no,
	d.dept_name, 
	FORMAT(AVG(salary),2) AS avg_salary
FROM salaries s
		JOIN
	dept_emp de ON s.emp_no = de.emp_no
		JOIN
	departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name
ORDER BY avg_salary DESC;

-------------------------------------------------------------------------------------------------------------------------

/*	 Select all hires this year		*/

SELECT *
FROM employees
WHERE YEAR(hire_date) = 2023;

-------------------------------------------------------------------------------------------------------------------------

/*	Select all managers hired in the last 5 years	*/

SELECT 
	*
FROM
	employees AS e
WHERE
	hire_date BETWEEN '01-01-2018' AND '01-01-2023'
		AND
	e.emp_no IN (
					SELECT 
						dm.emp_no
					FROM
						dept_manager dm
	);

-------------------------------------------------------------------------------------------------------------------------

/* 		Overview of positions		*/

SELECT DISTINCT
	title
FROM
	titles;

---------------------------------------------------------------------------------------------------------------------------

/* 	Select everyone with engineer roles in company		*/

SELECT 
	* 
FROM 
	titles
WHERE 
	title LIKE ('%engineer%');

---------------------------------------------------------------------------------------------------------------------------

/* 		Total and % of employees by position		*/

SELECT
	title,
    COUNT(DISTINCT(emp_no)) AS total_emp,
    ROUND(COUNT(DISTINCT(emp_no)) / (SELECT COUNT(*) FROM titles) * 100 ,1) AS '%'
FROM
	titles
GROUP BY
	1
ORDER BY
	3 DESC;

--------------------------------------------------------------------------------------------------------------------------

/* 		Average Salary by position		*/

SELECT 
	t.title, ROUND(AVG(s.salary),2) AS avg_salary
FROM	
	salaries s
		JOIN
	titles t ON s.emp_no = t.emp_no
GROUP BY
	title
ORDER BY
	avg_salary;

--------------------------------------------------------------------------------------------------------------------------    

-- Exploring Gender Diversity within positions, departments and salary.

-- General Gender Distribution in Company

SELECT
	gender, 
    COUNT(*) AS total_emp,
    ROUND(COUNT(emp_no) / (SELECT COUNT(*) FROM employees) * 100 ,1) AS '%'
FROM
	employees
GROUP BY
	gender;

--------------------------------------------------------------------------------------------------------------------------

-- Gender Distribution by department

   SELECT
	dept_name AS department,
	gender, 
    COUNT(*) AS total_emp,
    ROUND(	COUNT(e.emp_no) / (SELECT COUNT(*) FROM employees) * 100	,1) AS '%'
FROM
	employees e
		JOIN
	dept_emp de ON e.emp_no = de.emp_no
		JOIN
    departments d ON de.dept_no = d.dept_no
GROUP BY
	department, gender
ORDER BY
	1,3 DESC;

--------------------------------------------------------------------------------------------------------------------------

-- Gender Distribution by position

   SELECT
	title,
	gender, 
    COUNT(*) AS total_emp,
    ROUND(	COUNT(e.emp_no) / (SELECT COUNT(*) FROM employees) * 100	,1) AS '%'
FROM
	employees e
		JOIN
	titles t ON e.emp_no = t.emp_no
GROUP BY
	title, gender
ORDER BY
	1,3 DESC;

--------------------------------------------------------------------------------------------------------------------------

-- Average salary by gender in each department

SELECT 
	d.dept_name, 
    e.gender, 
    ROUND(AVG(s.salary),2) AS avg_salary
FROM
	employees AS e
		JOIN
	dept_emp AS de ON e.emp_no = de.emp_no
		JOIN
	salaries AS s ON e.emp_no = s.emp_no
		JOIN 
	departments AS d ON de.dept_no = d.dept_no
GROUP BY
	dept_name, gender
ORDER BY
	dept_name, avg_salary DESC;

--------------------------------------------------------------------------------------------------------------------------

-- Average salary by gender for each position

   SELECT
	title,
	gender, 
    ROUND(AVG(s.salary),2) AS avg_salary
FROM
	titles t
		JOIN
	employees e ON t.emp_no = e.emp_no
		JOIN
	salaries s ON t.emp_no = e.emp_no
GROUP BY
	title, gender
ORDER BY
	1,3 DESC;

--------------------------------------------------------------------------------------------------------------------------

-- Current managers table

SELECT
	title,
    dept_name
FROM
	titles t
		JOIN
	dept_manager dm ON t.emp_no = dm.emp_no
		JOIN
	departments d ON dm.dept_no = d.dept_no
WHERE
	title = 'Manager'
		AND
	YEAR(t.to_date) > 2023;

--------------------------------------------------------------------------------------------------------------------------

/*			Turnover rate by department		*/

/*	1. Overview of every column meaning	*/

SELECT
	*
FROM
	dept_emp;

--------------------------------------------------------------------------------------------------------------------------

/*	2. Check for duplicates (employees with many contracts)		*/

SELECT
	COUNT(from_date) - COUNT(DISTINCT(emp_no))
FROM
	dept_emp;

--------------------------------------------------------------------------------------------------------------------------

/*	3. Summarize in a table of departments total employees, retention and turnover rates 	*/


SELECT 
	d.dept_name,
    COUNT(DISTINCT(emp_no)) AS total_emp,
    COUNT(DISTINCT CASE WHEN de.to_date = max_date THEN emp_no END) AS workforce_now,
	total_emp - workforce_now AS total_turnovers,
    workforce_now / total_emp AS retention_rate,
    total_turnovers / total_emp AS turnover_rate
FROM
	departments d
		JOIN
	dept_emp de ON d.dept_no = de.dept_no
		JOIN (
        SELECT dept_no, MAX(to_date) AS max_date
        FROM dept_emp
        GROUP BY dept_no
    ) subq ON de.dept_no = subq.dept_no
GROUP BY
	d.dept_name;						

--------------------------------------------------------------------------------------------------------------------------

/*		4. Creating view for collabs to check dinamicaly		*/

CREATE OR REPLACE VIEW v_dept_emp_rates AS

SELECT 
	d.dept_name,
    COUNT(DISTINCT emp_no) AS total_emp,
    COUNT(DISTINCT CASE WHEN de.to_date = max_date THEN emp_no END) AS workforce_now,
    COUNT(DISTINCT emp_no) - COUNT(DISTINCT CASE WHEN de.to_date = max_date THEN emp_no END) AS total_turnovers,
    COUNT(DISTINCT CASE WHEN de.to_date = max_date THEN emp_no END) / COUNT(DISTINCT emp_no) AS retention_rate,
    (COUNT(DISTINCT emp_no) - COUNT(DISTINCT CASE WHEN de.to_date = max_date THEN emp_no END)) / COUNT(DISTINCT emp_no) AS turnover_rate
FROM
	departments d
    JOIN dept_emp de ON d.dept_no = de.dept_no
    JOIN (
        SELECT dept_no, MAX(to_date) AS max_date
        FROM dept_emp
        GROUP BY dept_no
    ) subq ON de.dept_no = subq.dept_no
GROUP BY
	d.dept_name;

---------------------------------------------------------------------------------------------------------------------------

/*		Create function that returns highest salary contract of employee		*/

DELIMITER $$

CREATE FUNCTION f_emp_info(p_first_name VARCHAR(255), p_last_name VARCHAR(255))
RETURNS DECIMAL(10,2)
DETERMINISTIC NO SQL READS SQL DATA

BEGIN
	DECLARE v_max_from_date DATE;
    
	DECLARE v_salary DECIMAL(10,2);
    
		SELECT 
			MAX(from_date)
		INTO 
			v_max_from_date
		FROM
			employees e
				JOIN
			salaries s ON e.emp_no = s.emp_no
		WHERE
			e.first_name = p_first_name
				AND
			e.last_name = p_last_name;
            
		SELECT
			s.salary
		INTO
			v_salary
		FROM
			salaries s
				JOIN
			employees e ON s.emp_no = e.emp_no
		WHERE
			e.first_name = p_first_name
				AND
			e.last_name = p_last_name
				AND
			s.from_date = v_max_from_date;

RETURN v_salary;
END$$

DELIMITER ;
;

---------------------------------------------------------------------------------------------------------------------------

/*	Use function and check it works correctly	*/

SELECT f_emp_info('Chirstian', 'Koblick');

---------------------------------------------------------------------------------------------------------------------------

/*		Using stored procedure to automate daily tasks (return last department where employee worked)	*/

DROP PROCEDURE IF EXISTS last_dept;

DELIMITER $$

CREATE PROCEDURE last_dept (in p_emp_no integer)
BEGIN
	SELECT
		e.emp_no, d.dept_no, d.dept_name
	FROM
		employees e
			JOIN
		dept_emp de ON e.emp_no = de.emp_no
			JOIN
		departments d ON de.dept_no = d.dept_no
	WHERE
		e.emp_no = p_emp_no
			AND
		de.from_date = (SELECT MAX(from_date) FROM dept_emp WHERE e.emp_no = p_emp_no);
END$$

DELIMITER ;
;

---------------------------------------------------------------------------------------------------------------------------

/*	Use procedure and check it works correctly	*/

CALL last_dept(10100);

----------------------------------------------------------------------------------------------------------------------------
