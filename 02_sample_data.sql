-- =====================================================================
-- Sample data for employee_unit_dw
-- Small, hand-crafted dataset so the star schema can be queried and
-- verified immediately after creation.
-- =====================================================================

USE employee_unit_dw;

-- ---------------------------------------------------------------------
-- dim_date: last 3 month-end dates, used as pay period markers
-- ---------------------------------------------------------------------
INSERT INTO dim_date (date_key, full_date, day_of_month, month_number, month_name, quarter_number, year_number, is_weekend) VALUES
(20260531, '2026-05-31', 31, 5, 'May',  2, 2026, FALSE),
(20260630, '2026-06-30', 30, 6, 'June', 2, 2026, FALSE),
(20260731, '2026-07-31', 31, 7, 'July', 3, 2026, FALSE);

-- ---------------------------------------------------------------------
-- dim_department
-- ---------------------------------------------------------------------
INSERT INTO dim_department (department_id, department_name, location) VALUES
('DEPT-01', 'Engineering', 'Coimbatore'),
('DEPT-02', 'Human Resources', 'Chennai'),
('DEPT-03', 'Sales', 'Bengaluru'),
('DEPT-04', 'Finance', 'Chennai');

-- ---------------------------------------------------------------------
-- dim_job_role
-- ---------------------------------------------------------------------
INSERT INTO dim_job_role (job_title, job_level, employment_type) VALUES
('Software Engineer',   'Mid',    'Full-Time'),
('Senior Software Engineer', 'Senior', 'Full-Time'),
('HR Executive',        'Junior', 'Full-Time'),
('Sales Associate',     'Junior', 'Full-Time'),
('Finance Analyst',     'Mid',    'Full-Time'),
('Engineering Lead',    'Lead',   'Full-Time');

-- ---------------------------------------------------------------------
-- dim_employee
-- ---------------------------------------------------------------------
INSERT INTO dim_employee (employee_id, first_name, last_name, gender, date_of_birth, hire_date, email) VALUES
('EMP-1001', 'Arun',    'Kumar',      'Male',   '1994-03-12', '2021-06-01', 'arun.kumar@company.com'),
('EMP-1002', 'Priya',   'Raman',      'Female', '1996-07-25', '2022-01-15', 'priya.raman@company.com'),
('EMP-1003', 'Vikram',  'Iyer',       'Male',   '1990-11-02', '2019-09-10', 'vikram.iyer@company.com'),
('EMP-1004', 'Sneha',   'Nair',       'Female', '1998-02-18', '2023-03-20', 'sneha.nair@company.com'),
('EMP-1005', 'Karthik', 'Subramaniam','Male',   '1992-05-30', '2020-11-05', 'karthik.s@company.com'),
('EMP-1006', 'Divya',   'Menon',      'Female', '1995-09-14', '2021-08-01', 'divya.menon@company.com');

-- ---------------------------------------------------------------------
-- fact_employee_payroll: 3 pay periods x 6 employees = 18 rows
-- Numbers are illustrative, not tied to any real payroll data.
-- ---------------------------------------------------------------------
INSERT INTO fact_employee_payroll
    (employee_key, department_key, job_role_key, date_key, hours_worked, base_salary, bonus_amount, deductions, net_pay)
VALUES
-- May 2026
(1, 1, 1, 20260531, 168, 65000, 2000, 1500, 65500),
(2, 2, 3, 20260531, 160, 42000,    0, 1200, 40800),
(3, 1, 6, 20260531, 172, 95000, 5000, 2200, 97800),
(4, 3, 4, 20260531, 160, 38000, 1000,  900, 38100),
(5, 4, 5, 20260531, 168, 58000,    0, 1400, 56600),
(6, 1, 2, 20260531, 170, 78000, 3000, 1800, 79200),

-- June 2026
(1, 1, 1, 20260630, 168, 65000, 1000, 1500, 64500),
(2, 2, 3, 20260630, 158, 42000,    0, 1200, 40800),
(3, 1, 6, 20260630, 176, 95000, 4000, 2200, 96800),
(4, 3, 4, 20260630, 160, 38000, 1500,  900, 38600),
(5, 4, 5, 20260630, 168, 58000,  500, 1400, 57100),
(6, 1, 2, 20260630, 172, 78000, 2500, 1800, 78700),

-- July 2026
(1, 1, 1, 20260731, 170, 66000, 1500, 1500, 66000),
(2, 2, 3, 20260731, 160, 42500,    0, 1200, 41300),
(3, 1, 6, 20260731, 174, 96000, 6000, 2300, 99700),
(4, 3, 4, 20260731, 162, 38500, 2000,  900, 39600),
(5, 4, 5, 20260731, 168, 58500,    0, 1400, 57100),
(6, 1, 2, 20260731, 170, 79000, 3500, 1900, 80600);
