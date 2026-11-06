-- ORDS MCP reports and custom SQL tools demo setup
--
-- Run this only in a throwaway test PDB.
-- Run the first section as SYS or another DBA user.
-- Then connect as PDBDBA and run the second section.
-- Change the passwords before running the script.

-- ================================================================
-- 1. Create the demo users
-- ================================================================

CREATE USER PDBDBA IDENTIFIED BY "ChangeMe_PDBDBA_123";
GRANT CREATE SESSION, CREATE TABLE TO PDBDBA;
ALTER USER PDBDBA QUOTA 100M ON USERS;

CREATE USER MCP_READER IDENTIFIED BY "ChangeMe_Reader_123";
GRANT CREATE SESSION TO MCP_READER;

-- ================================================================
-- 2. Connect as PDBDBA before running the rest
-- ================================================================

CREATE TABLE EMPLOYEES (
    employee_id NUMBER PRIMARY KEY,
    first_name  VARCHAR2(50) NOT NULL,
    last_name   VARCHAR2(50) NOT NULL,
    email       VARCHAR2(200),
    department  VARCHAR2(50) NOT NULL,
    job_title   VARCHAR2(100),
    salary      NUMBER(10, 2),
    hire_date   TIMESTAMP
);

INSERT INTO EMPLOYEES VALUES
    (1, 'Amina', 'Bennani', 'amina@example.com', 'Sales', 'Account Executive', 12000, TIMESTAMP '2025-01-15 09:00:00');

INSERT INTO EMPLOYEES VALUES
    (2, 'Youssef', 'Alaoui', 'youssef@example.com', 'Sales', 'Sales Manager', 18000, TIMESTAMP '2024-11-10 09:00:00');

INSERT INTO EMPLOYEES VALUES
    (3, 'Sara', 'Amrani', 'sara@example.com', 'Finance', 'Financial Analyst', 9000, TIMESTAMP '2026-02-20 09:00:00');

INSERT INTO EMPLOYEES VALUES
    (4, 'Omar', 'Idrissi', 'omar@example.com', 'Engineering', 'Software Engineer', 15000, TIMESTAMP '2025-06-01 09:00:00');

CREATE TABLE DBTOOLS$MCP_REPORTS (
    report_json JSON NOT NULL,
    id VARCHAR2(255)
       GENERATED ALWAYS AS (
           JSON_VALUE(
               report_json,
               '$.id' RETURNING VARCHAR2(255) ERROR ON ERROR
           )
       ) VIRTUAL,
    CONSTRAINT dbtools_mcp_reports_pk PRIMARY KEY (id)
);

INSERT INTO DBTOOLS$MCP_REPORTS (report_json)
VALUES (
    JSON_OBJECT(
        'id' VALUE 'demo-employee-directory-by-department-schema',
        'displayName' VALUE 'Employee Directory by Department (Schema)',
        'description' VALUE 'Lists employees in a selected department.',
        'purpose' VALUE 'Answer employee-directory questions with a schema-level report.',
        'instructions' VALUE 'Provide the department name as text.',
        'source' VALUE q'~
            SELECT employee_id, first_name, last_name, email,
                   department, job_title, salary, hire_date
            FROM EMPLOYEES
            WHERE UPPER(TRIM(department)) = UPPER(TRIM(:department_name))
            ORDER BY last_name, first_name
        ~',
        'variables' VALUE JSON_ARRAY(
            JSON_OBJECT(
                'name' VALUE 'department_name',
                'type' VALUE 'VARCHAR2',
                'description' VALUE 'Department name, such as Sales or Finance.'
            )
        )
        RETURNING JSON
    )
);

GRANT SELECT ON EMPLOYEES TO MCP_READER;

COMMIT;
