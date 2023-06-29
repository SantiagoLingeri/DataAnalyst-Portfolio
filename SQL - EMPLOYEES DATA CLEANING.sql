                                          /*	EMPLOYEES DATABASE CLEANING */

/* 
  - In this project the goal was to look through a large raw HR Database, find and manage missing data, duplicates and inconsistencies in order to get clean data, ready for a complex analysis. 
  - Throughout the cleaning process, I find Insights about the Data Modeling that could lead to issues in everyday data handling. 
  - Finaly, I designed and applied a practical solution to filter out ex-employees and easily get a view of only current employees info.
  - Data was provided by "365 Data Science" in their SQL Certification Course.

### Project Results
---------------------------------------------------------------------------------------------------------------------------------------
> Missing values ❗ 73      > ✅ 0
> Empty Columns  ❗ 1       > ✅ 0 
> Duplicates     ❗ +30,000 > ✅ 0
---------------------------------------------------------------------------------------------------------------------------------------
> Consistency    ❗ Low (incompatible contracts, mixed old and current) > ✅ High (Can Filter only current employees)
---------------------------------------------------------------------------------------------------------------------------------------
> Usability      ❗ Very Low (Many potential errors)                    > ✅ Ready for Analysis
---------------------------------------------------------------------------------------------------------------------------------------

*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  /*	Select database to work with	*/

USE employees;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*		Overview of raw data		*/

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

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  /*	DROP EMPTY COLUMN	*/

ALTER TABLE employees
DROP COLUMN emp_address;
												
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  /*	HANDLING NULL VALUES
                                                        
        1. Find missing data
        2. Replace when posible. 
        3. If not, delete incomplete rows.	*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Start with Employees table */

SELECT
	*
FROM
	employees
WHERE
	birth_date IS NULL
		OR
	first_name IS NULL
		OR
  last_name IS NULL
		OR
  gender IS NULL
		OR
  hire_date IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Missing hire dates can be saved from contracts info */

UPDATE 
	employees
SET 
	hire_date = (SELECT MIN(from_date) FROM salaries)
WHERE 
	hire_date IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Departments Table */

SELECT
	*
FROM
	departments
WHERE
	dept_name IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Dept Emp Table */

SELECT
	*
FROM
	dept_emp
WHERE
	dept_no	IS NULL
		OR
	from_date IS NULL
		OR
    to_date	IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Dept Manager Table */

SELECT
	*
FROM
	dept_manager
WHERE
	dept_no	IS NULL
		OR
	from_date IS NULL
		OR
    to_date	IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Salaries Table */

SELECT
	*
FROM
	salaries
WHERE
	salary IS NULL
		OR
	from_date IS NULL
		OR
    to_date	IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Missing salaries can be replaced with average salary */

UPDATE salaries s
SET salary = (
    SELECT AVG(avg_salary)
    FROM (
        SELECT AVG(salary) AS avg_salary
        FROM salaries s1
        JOIN dept_emp de ON s1.emp_no = de.emp_no
        JOIN titles t ON s1.emp_no = t.emp_no
        GROUP BY t.title, de.dept_no
    ) AS subquery
)
WHERE salary IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Titles Table */

SELECT
	*
FROM
	titles
WHERE
	title IS NULL
		OR
	from_date IS NULL
		OR
    to_date IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Deleting entries with incomplete job titles */

DELETE FROM titles
WHERE title IS NULL;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

													/*	HANDLING DUPLICATE VALUES	*/

													/* Finding duplicates */

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Employees table (0 duplicates) */

SELECT 
	emp_no, 
	COUNT(*) AS count
FROM 
	employees
GROUP BY 
	1
HAVING 
	COUNT(*) > 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Departments Table (1 duplicate) */

SELECT 
	dept_no, 
	COUNT(*) AS count
FROM 
	departments
GROUP BY 
	1
HAVING 
	COUNT(*) > 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Dept Emp Table (many duplicates) */

SELECT 
	emp_no, 
	COUNT(emp_no) AS count
FROM 
	dept_emp
WHERE
	to_date > CURRENT_DATE
GROUP BY 
	1
HAVING 
	COUNT(emp_no) > 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Counting duplicates (31579) */

SELECT 
    COUNT(count) AS total_duplicates
FROM 
    (
    SELECT 
        emp_no,
        COUNT(emp_no) AS count
    FROM 
        dept_emp
    GROUP BY 
        emp_no
    HAVING 
        COUNT(emp_no) > 1
    ) AS duplicate_groups;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Dept Manager Table (0 duplicates) */

SELECT
	emp_no,
	COUNT(emp_no) AS count
FROM
	dept_manager
GROUP BY
	1
HAVING
	COUNT(emp_no) > 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Salaries Table (lots of duplicates) */

SELECT 
	emp_no, 
	COUNT(emp_no) AS count
FROM 
	salaries
GROUP BY
	1
HAVING 
	COUNT(emp_no) > 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Check why some employees have up to 18 entries in salaries */

SELECT 
	*,
    title,
    dept_name
FROM 
	salaries s
		JOIN
	titles t ON s.emp_no = t.emp_no
		JOIN
	dept_emp de ON s.emp_no = de.emp_no
		JOIN
	departments d ON de.dept_no = d.dept_no
WHERE
	s.emp_no = 10001
    OR
    s.emp_no = 10009;

/* Result: Although maintaining position and department, they renegociate a raise every year */

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Titles Table (many duplicates) */

SELECT 
	emp_no, 
	COUNT(emp_no) AS count
FROM 
	titles
GROUP BY 
	1
HAVING 
	COUNT(emp_no) > 1;

SELECT *
FROM titles
WHERE emp_no = 10009;

SELECT *
FROM salaries
WHERE emp_no = 10009;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

													/*	Removing duplicates	*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Departments Table */

DELETE FROM departments
WHERE dept_no = 'd011';

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Dept Emp Table */

DELETE FROM dept_emp
WHERE emp_no IN (
		SELECT 
			emp_no
		WHERE
			to_date > CURRENT_DATE
		GROUP BY 
			emp_no
		HAVING 
			COUNT(emp_no) > 1
    );

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Data Modeling Insight and improvement:

	This Database design includes finished and current employee contracts. Current contracts with no termination date, have a "to_date" default value of "9999-01-01"   
	 Undertanding the problem in-depth, let's create an everyday practical solution for colaborators using this database. 
	
    */

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Create views to filter only current employees in each table */

CREATE OR REPLACE VIEW v_todays_employees AS
SELECT *
FROM dept_emp
WHERE to_date > CURRENT_DATE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_todays_managers AS
SELECT *
FROM dept_manager
WHERE to_date > CURRENT_DATE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_todays_salaries AS
SELECT *
FROM salaries
WHERE to_date > CURRENT_DATE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_todays_positions AS
SELECT *
FROM titles
WHERE to_date > CURRENT_DATE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Call a view to check it works correctly */

SELECT *
FROM v_todays_employees;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

															/* Data is ready for analysis */