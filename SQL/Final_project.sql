/*1.  Покажіть середню зарплату за кожен рік.
SELECT YEAR(from_date) AS report_year,
    ROUND(AVG(salary), 2) AS avg_sal
FROM employees.salaries AS s
GROUP BY report_year
HAVING report_year BETWEEN MIN(report_year) AND 2005
ORDER BY report_year;


2.  Покажіть середню зарплату співробітників у кожному відділу. Примітка: візьміть поточні відділи та поточну зарплату.
SELECT d.dept_name,
    ROUND(AVG(salary), 2) AS avg_sal
FROM dept_emp AS de
JOIN salaries s ON de.emp_no = s.emp_no
	AND CURDATE() BETWEEN s.from_date AND s.to_date
	AND CURDATE() BETWEEN de.from_date AND de.to_date
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY de.dept_no
ORDER BY d.dept_name;

3.  Покажіть середню зарплату працівників у кожному відділі за кожен рік.

SELECT d.dept_name,
	YEAR(de.from_date) AS report_year,
    ROUND(AVG(salary), 2) AS avg_sal
FROM dept_emp de
JOIN salaries s ON de.emp_no = s.emp_no
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name, report_year
ORDER BY report_year;

4.  Покажіть для кожного року найбільший відділ цього року та його середню зарплату.*/


WITH sub AS (
    -- Отримуємо інформацію про кількість співробітників та середню зарплату по кожному відділу за кожен рік
    SELECT de.dept_no, d.dept_name,   
        EXTRACT(YEAR FROM s.to_date) AS report_year, 
        COUNT(de.emp_no) AS empl_count,  
        ROUND(AVG(s.salary), 2) AS average_salary        
    FROM employees.dept_emp AS de   
        INNER JOIN employees.departments AS d 
            ON d.dept_no = de.dept_no  
        INNER JOIN employees.salaries AS s 
            ON de.emp_no = s.emp_no   
    GROUP BY 1, 3
), max_count AS (
    -- Визначаємо максимальну кількість співробітників для кожного року
    SELECT report_year, MAX(empl_count) AS max_empl_count   
    FROM sub   
    GROUP BY 1
), max_year AS (
    -- Отримуємо останній доступний рік у даних
    SELECT MAX(report_year) AS max_year
    FROM sub
)
SELECT sub.dept_no, sub.dept_name,      
    -- Визначаємо, чи є поточний рік найновішим у даних, якщо так – виводимо 'current year'
    CASE 
        WHEN sub.report_year = max_year.max_year THEN 'current year'
        ELSE sub.report_year
    END AS report_year, 
    sub.empl_count, sub.average_salary
FROM sub
    INNER JOIN max_count   
        ON sub.report_year = max_count.report_year   
        AND sub.empl_count = max_count.max_empl_count
    INNER JOIN max_year
ORDER BY report_year;


/*WITH dept_sizes AS (SELECT YEAR(de.from_date) AS report_year, d.dept_name,
						COUNT(DISTINCT de.emp_no) AS emp_count,
						ROUND(AVG(s.salary), 2) AS avg_sal
					FROM dept_emp AS de
					JOIN salaries s ON de.emp_no = s.emp_no
						AND CURDATE() BETWEEN s.from_date AND s.to_date
						AND CURDATE() BETWEEN de.from_date AND de.to_date
					JOIN departments d ON de.dept_no = d.dept_no
					GROUP BY report_year, d.dept_name
),
  ranked_depts AS (SELECT report_year, dept_name, avg_sal,
					ROW_NUMBER() OVER (PARTITION BY report_year ORDER BY emp_count DESC) AS rnk
				  FROM dept_sizes
)
SELECT report_year, dept_name AS biggest_department, avg_sal
FROM ranked_depts
WHERE rnk = 1
ORDER BY report_year;

5.  Покажіть детальну інформацію про поточного менеджера, який найдовше виконує свої обов'язки.

SELECT dm.emp_no, d.dept_name, e.last_name, e.hire_date
FROM dept_manager AS dm
JOIN employees AS e ON dm.emp_no = e.emp_no
	AND CURDATE() BETWEEN dm.from_date AND dm.to_date
JOIN departments AS d ON dm.dept_no = d.dept_no
WHERE TIMESTAMPDIFF(DAY, e.hire_date, CURDATE()) = 
	(SELECT MAX(TIMESTAMPDIFF(DAY, e2.hire_date, CURDATE()))
    FROM dept_manager AS dm2
    JOIN employees AS e2 ON dm2.emp_no = e2.emp_no
		AND CURDATE() BETWEEN dm2.from_date AND dm2.to_date);
    
SELECT dm.emp_no, d.dept_name, hire_date, last_name
FROM employees.employees e
JOIN  employees.dept_manager dm
ON dm.emp_no=e.emp_no AND dm.to_date>NOW()
JOIN employees.departments d 
ON dm.dept_no=d.dept_no 
WHERE TIMESTAMPDIFF(YEAR, e.hire_date, NOW())=
	(SELECT MAX(TIMESTAMPDIFF(YEAR, e.hire_date, NOW()))
     FROM employees.employees e)


*/