-- =============================================================================
-- SQL TASK 01: RELATIONAL DATABASE SCHEMA DESIGN & INTEGRITY CONSTRAINTS
-- Enterprise Branch & Manager Operational Architecture
-- Author: Islam Yasser (Data Analyst & BI Specialist)
-- Target RDBMS: MySQL 8.0+
-- =============================================================================

-- Step 1: Initialize Database Environment
DROP DATABASE IF EXISTS manages;
CREATE DATABASE manages 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE manages;

-- =============================================================================
-- Step 2: Table Definitions (DDL)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Entity 1: Manager
-- Description: Stores managerial personnel details, enforcing positive compensation.
-- Integrity Rules:
--   - empNo: Primary Key with auto-increment sequence.
--   - salary: Strictly positive numeric value (CHECK constraint).
-- -----------------------------------------------------------------------------
CREATE TABLE Manager (
    empNo INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_manager_salary CHECK (salary > 0)
);

-- -----------------------------------------------------------------------------
-- Entity 2: Branch
-- Description: Stores physical branch locations, asset valuations, and assigned managers.
-- Integrity Rules:
--   - BranchNo: Primary Key with auto-increment sequence.
--   - empNo: Foreign Key establishing a 1-to-Many relationship (One Manager -> Multiple Branches).
-- -----------------------------------------------------------------------------
CREATE TABLE Branch (
    BranchNo INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(100) NOT NULL,
    assets VARCHAR(100) NOT NULL,
    empNo INT,
    CONSTRAINT fk_branch_manager FOREIGN KEY (empNo) 
        REFERENCES Manager(empNo)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- =============================================================================
-- Step 3: Verification Seed Data (DML)
-- =============================================================================

-- Insert Sample Managers
INSERT INTO Manager (name, salary) VALUES
    ('Ahmed El-Sayed', 28500.00),
    ('Mona El-Shamy', 34000.00),
    ('Khaled Mahmoud', 31200.00),
    ('Nourhan Tarek', 29800.00);

-- Insert Sample Branches Managed by Personnel
INSERT INTO Branch (address, assets, empNo) VALUES
    ('15 Tahrir Square, Downtown, Cairo', '$1,250,000 Capital Assets', 1),
    ('42 El-Horreya Avenue, Alexandria', '$850,000 Logistics Hub', 2),
    ('90th Street North, New Cairo', '$2,100,000 Flagship Retail', 1),
    ('Giza Plateau Road, Giza', '$650,000 Warehouse Annex', 3),
    ('Corniche El-Nil, Maadi, Cairo', '$920,000 Corporate Center', NULL);

-- =============================================================================
-- Step 4: Verification Queries & Relational Integrity Validation
-- =============================================================================

-- Query 1: Display all branches along with their assigned manager details
SELECT 
    b.BranchNo,
    b.address AS branch_address,
    b.assets AS branch_assets,
    COALESCE(m.name, 'Unassigned / Vacant') AS manager_name,
    COALESCE(CONCAT('$', FORMAT(m.salary, 2)), 'N/A') AS manager_salary
FROM Branch b
LEFT JOIN Manager m ON b.empNo = m.empNo
ORDER BY b.BranchNo ASC;

-- Query 2: Aggregate branches and total asset coverage per manager
SELECT 
    m.empNo,
    m.name AS manager_name,
    m.salary,
    COUNT(b.BranchNo) AS managed_branches_count
FROM Manager m
LEFT JOIN Branch b ON m.empNo = b.empNo
GROUP BY m.empNo, m.name, m.salary
ORDER BY managed_branches_count DESC;

-- -----------------------------------------------------------------------------
-- Step 5: Constraint Integrity Tests (Negative Test Cases)
-- Note: Uncomment lines below to test database constraint enforcement.
-- -----------------------------------------------------------------------------

-- Test Case A: Salary Check Constraint Violation (Must Fail with error 3819)
-- INSERT INTO Manager (name, salary) VALUES ('Invalid Salary Test', -5000.00);

-- Test Case B: Foreign Key Referential Integrity Violation (Must Fail with error 1452)
-- INSERT INTO Branch (address, assets, empNo) VALUES ('Invalid Branch Test', 'Assets', 9999);
