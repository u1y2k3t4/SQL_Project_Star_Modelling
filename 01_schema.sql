-- =====================================================================
-- Employee Unit - Star Schema
-- =====================================================================
-- Grain of the fact table: one row per employee, per pay period (month).
-- Written for MySQL 8+ / MariaDB. Easily portable to PostgreSQL by
-- swapping AUTO_INCREMENT -> GENERATED ALWAYS AS IDENTITY / SERIAL.
-- =====================================================================

DROP DATABASE IF EXISTS employee_unit_dw;
CREATE DATABASE employee_unit_dw;
USE employee_unit_dw;

-- ---------------------------------------------------------------------
-- DIMENSION: Date
-- One row per calendar date used anywhere in the fact table.
-- Pre-built date dimensions make time-based reporting (by month,
-- quarter, year) fast without recalculating from raw dates each query.
-- ---------------------------------------------------------------------
CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,          -- surrogate key, format YYYYMMDD
    full_date        DATE NOT NULL,
    day_of_month     TINYINT NOT NULL,
    month_number     TINYINT NOT NULL,
    month_name       VARCHAR(10) NOT NULL,
    quarter_number   TINYINT NOT NULL,
    year_number      SMALLINT NOT NULL,
    is_weekend       BOOLEAN NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- DIMENSION: Employee
-- Descriptive attributes about each employee. Kept separate from the
-- fact table so an employee's details only need updating in one place.
-- ---------------------------------------------------------------------
CREATE TABLE dim_employee (
    employee_key     INT AUTO_INCREMENT PRIMARY KEY,  -- surrogate key
    employee_id      VARCHAR(15) NOT NULL UNIQUE,      -- natural/business key
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    gender           VARCHAR(10),
    date_of_birth    DATE,
    hire_date        DATE NOT NULL,
    email            VARCHAR(100)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- DIMENSION: Department
-- ---------------------------------------------------------------------
CREATE TABLE dim_department (
    department_key   INT AUTO_INCREMENT PRIMARY KEY,
    department_id    VARCHAR(10) NOT NULL UNIQUE,
    department_name  VARCHAR(100) NOT NULL,
    location         VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- DIMENSION: Job Role
-- Separated from Employee because job titles/levels are reused across
-- many employees and can change over time independently of who holds them.
-- ---------------------------------------------------------------------
CREATE TABLE dim_job_role (
    job_role_key     INT AUTO_INCREMENT PRIMARY KEY,
    job_title        VARCHAR(100) NOT NULL,
    job_level        VARCHAR(30) NOT NULL,       -- e.g. Junior, Mid, Senior, Lead
    employment_type  VARCHAR(20) NOT NULL         -- e.g. Full-Time, Part-Time, Contract
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- FACT: Employee Payroll
-- Grain: one row per employee per pay period. Measures are numeric and
-- additive (safe to SUM across any dimension) except net_pay, which is
-- derived but still additive for reporting convenience.
-- ---------------------------------------------------------------------
CREATE TABLE fact_employee_payroll (
    payroll_fact_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_key     INT NOT NULL,
    department_key   INT NOT NULL,
    job_role_key     INT NOT NULL,
    date_key         INT NOT NULL,               -- pay period date (e.g. month end)
    hours_worked     DECIMAL(6,2) NOT NULL,
    base_salary      DECIMAL(12,2) NOT NULL,
    bonus_amount     DECIMAL(12,2) NOT NULL DEFAULT 0,
    deductions       DECIMAL(12,2) NOT NULL DEFAULT 0,
    net_pay          DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_fact_employee
        FOREIGN KEY (employee_key) REFERENCES dim_employee(employee_key),
    CONSTRAINT fk_fact_department
        FOREIGN KEY (department_key) REFERENCES dim_department(department_key),
    CONSTRAINT fk_fact_job_role
        FOREIGN KEY (job_role_key) REFERENCES dim_job_role(job_role_key),
    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
) ENGINE=InnoDB;

-- Helpful indexes for typical star-schema query patterns (filtering/
-- joining on each dimension key from the fact table).
CREATE INDEX idx_fact_employee   ON fact_employee_payroll(employee_key);
CREATE INDEX idx_fact_department ON fact_employee_payroll(department_key);
CREATE INDEX idx_fact_job_role   ON fact_employee_payroll(job_role_key);
CREATE INDEX idx_fact_date       ON fact_employee_payroll(date_key);
