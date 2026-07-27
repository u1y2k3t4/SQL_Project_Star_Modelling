# Employee Unit — Star Schema Data Warehouse

A small star-schema database for reporting on employee payroll: one
fact table surrounded by four dimension tables. Built and tested
against MySQL 8 / MariaDB.

## Schema diagram

```
                    dim_date
                        │
                        │
  dim_employee ── fact_employee_payroll ── dim_department
                        │
                        │
                   dim_job_role
```

## Tables

| Table | Type | Grain / Purpose |
|---|---|---|
| `dim_date` | Dimension | One row per calendar date used as a pay period marker |
| `dim_employee` | Dimension | One row per employee (name, DOB, hire date, contact) |
| `dim_department` | Dimension | One row per department (name, location) |
| `dim_job_role` | Dimension | One row per job title / level / employment type |
| `fact_employee_payroll` | Fact | One row per employee, per pay period — hours worked, base salary, bonus, deductions, net pay |

### Why this design

- **Grain is "one employee, one pay period."** Every measure in the
  fact table (hours, salary, bonus, deductions, net pay) is additive
  at that grain, so `SUM()` across any dimension combination gives a
  correct answer — no double-counting.
- **Job role is its own dimension, not a column on `dim_employee`.**
  Titles and levels are shared across many employees and are a
  natural attribute to slice payroll by (e.g. "average bonus per job
  level"), so splitting it out avoids repeating that text on every
  employee row.
- **`dim_date` is a real dimension table, not a raw `DATE` column on
  the fact table.** It's a standard star-schema pattern — it makes
  grouping by month/quarter/year cheap and lets you add fiscal-period
  logic later without touching the fact table.

## Files

- `01_schema.sql` — creates the database and all 5 tables (4 dimensions + 1 fact), with foreign keys and indexes
- `02_sample_data.sql` — seeds 6 employees across 4 departments, 3 monthly pay periods (18 fact rows)
- `03_sample_queries.sql` — 5 example queries: department totals, pay trends, average bonus by level, hours+pay by location, and a month-over-month raise check

## Running it

```bash
mysql -u root < 01_schema.sql
mysql -u root < 02_sample_data.sql
mysql -u root < 03_sample_queries.sql
```

Each script was run and verified locally before delivery — the sample
queries return real, correct aggregated results against the seed data
(e.g. Engineering department: 3 employees, ₹7,28,800 total net pay
across the 3 pay periods).

## Possible next steps

- Add a `dim_manager` or self-referencing hierarchy on `dim_employee` for org-chart rollups
- Extend `dim_date` to cover a full year with fiscal quarter logic
- Add a slowly-changing-dimension (SCD Type 2) strategy for department/job-role history
