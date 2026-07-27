-- =====================================================================
-- Sample analytical queries against the employee_unit_dw star schema
-- These demonstrate the typical pattern: join the fact table to one
-- or more dimensions, then aggregate.
-- =====================================================================

USE employee_unit_dw;

-- 1. Total net pay by department, for the latest pay period
SELECT
    d.department_name,
    dt.month_name,
    dt.year_number,
    SUM(f.net_pay) AS total_net_pay
FROM fact_employee_payroll f
JOIN dim_department d ON f.department_key = d.department_key
JOIN dim_date dt       ON f.date_key = dt.date_key
WHERE dt.date_key = 20260731
GROUP BY d.department_name, dt.month_name, dt.year_number
ORDER BY total_net_pay DESC;

-- 2. Month-over-month net pay trend per employee
SELECT
    e.first_name,
    e.last_name,
    dt.month_name,
    dt.year_number,
    f.net_pay
FROM fact_employee_payroll f
JOIN dim_employee e ON f.employee_key = e.employee_key
JOIN dim_date dt     ON f.date_key = dt.date_key
ORDER BY e.employee_id, dt.date_key;

-- 3. Average bonus by job level, across all pay periods
SELECT
    jr.job_level,
    ROUND(AVG(f.bonus_amount), 2) AS avg_bonus
FROM fact_employee_payroll f
JOIN dim_job_role jr ON f.job_role_key = jr.job_role_key
GROUP BY jr.job_level
ORDER BY avg_bonus DESC;

-- 4. Total hours worked and total pay by department + location
SELECT
    d.department_name,
    d.location,
    SUM(f.hours_worked) AS total_hours,
    SUM(f.net_pay)       AS total_net_pay
FROM fact_employee_payroll f
JOIN dim_department d ON f.department_key = d.department_key
GROUP BY d.department_name, d.location
ORDER BY total_net_pay DESC;

-- 5. Employees whose July net pay is higher than their May net pay
--    (a simple "raise / bonus increase" check using self-joins on the fact table)
SELECT
    e.first_name,
    e.last_name,
    may.net_pay  AS may_net_pay,
    jul.net_pay  AS july_net_pay,
    (jul.net_pay - may.net_pay) AS pay_change
FROM fact_employee_payroll may
JOIN fact_employee_payroll jul
    ON may.employee_key = jul.employee_key
    AND may.date_key = 20260531
    AND jul.date_key = 20260731
JOIN dim_employee e ON e.employee_key = may.employee_key
WHERE jul.net_pay > may.net_pay
ORDER BY pay_change DESC;
