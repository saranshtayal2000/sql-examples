USE employees_mod;

SELECT 
    YEAR(d.from_date) AS calendar_year,
    e.gender AS gender,
    COUNT(e.emp_no) AS num_of_employees
FROM
    t_dept_emp d
        JOIN
    t_employees e ON d.emp_no = e.emp_no
GROUP BY calendar_year , gender
HAVING calendar_year >= 1990
ORDER BY calendar_year;

-------------------------------------------------------------------------------
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN
            calendar_year >= YEAR(dm.from_date)
                AND e.calendar_year <= YEAR(dm.to_date)
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no , e.calendar_year;

USE employees_mod;
----------------------------------------------------------------------------------
SELECT 
    e.gender AS gender,
    d.dept_name AS dept_name,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(de.from_date) AS calendar_year
FROM
    t_employees e
        JOIN
    t_salaries s ON e.emp_no = s.emp_no
        JOIN
    t_dept_emp de ON s.emp_no = de.emp_no
        JOIN
    t_departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_no , e.gender , calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;
--------------------------------------------------------------------
DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT , IN p_max_salary FLOAT)
BEGIN
SELECT
	e.gender, d.dept_name, AVG(s.salary) as avg_salary
    FROM
    t_salaries s JOIN
    t_employees e ON s.emp_no = e.emp_no
    JOIN t_dept_emp de ON de.emp_no = e.emp_no
    JOIN t_departments d ON d.dept_no = de.dept_no
    WHERE s.salary BETWEEN p_min_salary AND p_max_salary
    GROUP BY d.dept_no , e.gender;
    END$$
    DELIMITER ;
    CALL filter_salary(50000, 90000) ;

