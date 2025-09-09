create database InvestigationDB;
use InvestigationDB;

#Define Schema----------
CREATE TABLE Officers (
    officer_id SERIAL PRIMARY KEY,
    officer_name VARCHAR(100) NOT NULL,
    rank VARCHAR(50),
    department VARCHAR(100),
    contact_info VARCHAR(100)
);
desc officers;

CREATE TABLE Cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    case_title VARCHAR(200) NOT NULL,
    case_status ENUM('solved','unsolved') DEFAULT 'unsolved',
    opened_date DATE NOT NULL,
    closed_date DATE,
    officer_id INT,
    CONSTRAINT fk_officer FOREIGN KEY (officer_id) REFERENCES Officers(officer_id) ON DELETE SET NULL
);
desc cases;

CREATE TABLE Suspects (
    suspect_id INT AUTO_INCREMENT PRIMARY KEY,
    suspect_name VARCHAR(100) NOT NULL,
    age INT,
    gender ENUM('male','female','other'),
    address TEXT,
    case_id INT,
    CONSTRAINT fk_case FOREIGN KEY (case_id) REFERENCES Cases(case_id) ON DELETE CASCADE
);
desc suspects;

CREATE TABLE Evidence (
    evidence_id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT,
    description TEXT NOT NULL,
    collected_date DATE NOT NULL,
    chain_of_custody TEXT,
    CONSTRAINT fk_case_evidence FOREIGN KEY (case_id) REFERENCES Cases(case_id) ON DELETE CASCADE
);
desc evidence;
#Indexing---------
CREATE INDEX idx_case_id ON Cases(case_id);
CREATE INDEX idx_suspect_name ON Suspects(suspect_name);

#Queries----------
SELECT case_id, case_title, opened_date
FROM Cases
WHERE case_status = 'unsolved';

SELECT case_id, case_title, closed_date
FROM Cases
WHERE case_status = 'solved';

SELECT case_status, COUNT(*) AS total_cases
FROM Cases
GROUP BY case_status;

#Views-----------
CREATE VIEW officer_workloads AS
SELECT o.officer_id, o.officer_name, COUNT(c.case_id) AS total_cases
FROM Officers o
LEFT JOIN Cases c ON o.officer_id = c.officer_id
GROUP BY o.officer_id, o.officer_name;

#Triggers------------
DELIMITER $$

CREATE TRIGGER trg_update_chain_of_custody
BEFORE INSERT ON Evidence
FOR EACH ROW
BEGIN
   SET NEW.chain_of_custody = CONCAT(
       'Collected by Officer ID ',
       (SELECT officer_id FROM Cases WHERE case_id = NEW.case_id),
       ' on ',
       CURRENT_DATE
   );
END$$

DELIMITER ;

#Investigation Summary Report-------------
CREATE VIEW investigation_summary AS
SELECT 
    c.case_id,
    c.case_title,
    c.case_status,
    c.opened_date,
    c.closed_date,
    o.officer_name,
    GROUP_CONCAT(DISTINCT s.suspect_name) AS suspects,
    GROUP_CONCAT(DISTINCT e.description) AS evidences
FROM Cases c
LEFT JOIN Officers o ON c.officer_id = o.officer_id
LEFT JOIN Suspects s ON c.case_id = s.case_id
LEFT JOIN Evidence e ON c.case_id = e.case_id
GROUP BY c.case_id, c.case_title, c.case_status, c.opened_date, c.closed_date, o.officer_name;

-- Use your database
USE InvestigationDB;

-- Officers Table
CREATE TABLE IF NOT EXISTS Officers (
    officer_id INT AUTO_INCREMENT PRIMARY KEY,
    officer_name VARCHAR(100),
    rank VARCHAR(50)
    -- Add other columns as needed
);

-- Cases Table
CREATE TABLE IF NOT EXISTS Cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    case_title VARCHAR(100),
    case_status ENUM('solved','unsolved') DEFAULT 'unsolved',
    opened_date DATE,
    closed_date DATE,
    officer_id INT,
    FOREIGN KEY (officer_id) REFERENCES Officers(officer_id)
);

-- Suspects Table
CREATE TABLE IF NOT EXISTS Suspects (
    suspect_id INT AUTO_INCREMENT PRIMARY KEY,
    suspect_name VARCHAR(100),
    age INT,
    gender ENUM('Male','Female','Other')
    -- Add other columns
);

-- Victims Table
CREATE TABLE IF NOT EXISTS Victims (
    victim_id INT AUTO_INCREMENT PRIMARY KEY,
    victim_name VARCHAR(100),
    age INT,
    gender ENUM('Male','Female','Other')
    -- Add other columns
);

-- Evidence Table
CREATE TABLE IF NOT EXISTS Evidence (
    evidence_id INT AUTO_INCREMENT PRIMARY KEY,
    evidence_type VARCHAR(50),
    description TEXT,
    case_id INT,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);

-- Example of View (if needed)
CREATE OR REPLACE VIEW case_officer_details AS
SELECT c.case_id, c.case_title, o.officer_name, c.case_status
FROM Cases c
JOIN Officers o ON c.officer_id = o.officer_id;

-- Example of Stored Procedure (if needed)
DELIMITER //
CREATE PROCEDURE GetOpenCases()
BEGIN
    SELECT * FROM Cases WHERE case_status = 'unsolved';
END //
DELIMITER ;

-- Use the database
USE InvestigationDB;

-----------------------------------------------------
-- Officers Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Officers (
    officer_id INT AUTO_INCREMENT PRIMARY KEY,
    officer_name VARCHAR(100),
    rank VARCHAR(50)
    -- Add other columns as needed
);

-----------------------------------------------------
-- Cases Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    case_title VARCHAR(100),
    case_status ENUM('solved','unsolved') DEFAULT 'unsolved',
    opened_date DATE,
    closed_date DATE,
    officer_id INT,
    FOREIGN KEY (officer_id) REFERENCES Officers(officer_id)
);

-----------------------------------------------------
-- Suspects Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Suspects (
    suspect_id INT AUTO_INCREMENT PRIMARY KEY,
    suspect_name VARCHAR(100),
    age INT,
    gender ENUM('Male','Female','Other')
    -- Add other columns
);

-----------------------------------------------------
-- Victims Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Victims (
    victim_id INT AUTO_INCREMENT PRIMARY KEY,
    victim_name VARCHAR(100),
    age INT,
    gender ENUM('Male','Female','Other')
    -- Add other columns
);

-----------------------------------------------------
-- Evidence Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Evidence (
    evidence_id INT AUTO_INCREMENT PRIMARY KEY,
    evidence_type VARCHAR(50),
    description TEXT,
    case_id INT,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);

-----------------------------------------------------
-- Witnesses Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Witnesses (
    witness_id INT AUTO_INCREMENT PRIMARY KEY,
    witness_name VARCHAR(100),
    statement TEXT,
    case_id INT,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);

-----------------------------------------------------
-- Example Views
-----------------------------------------------------
CREATE OR REPLACE VIEW case_officer_details AS
SELECT c.case_id, c.case_title, o.officer_name, c.case_status
FROM Cases c
JOIN Officers o ON c.officer_id = o.officer_id;

CREATE OR REPLACE VIEW case_evidence_details AS
SELECT c.case_id, c.case_title, e.evidence_type, e.description
FROM Cases c
JOIN Evidence e ON c.case_id = e.case_id;

-----------------------------------------------------
-- Example Stored Procedures
-----------------------------------------------------
DELIMITER //
CREATE PROCEDURE GetOpenCases()
BEGIN
    SELECT * FROM Cases WHERE case_status = 'unsolved';
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetOfficerCases(IN officer INT)
BEGIN
    SELECT * FROM Cases WHERE officer_id = officer;
END //
DELIMITER ;

-----------------------------------------------------
-- Example Trigger
-----------------------------------------------------
DELIMITER //
CREATE TRIGGER set_closed_date
BEFORE UPDATE ON Cases
FOR EACH ROW
BEGIN
    IF NEW.case_status = 'solved' AND OLD.case_status <> 'solved' THEN
        SET NEW.closed_date = CURDATE();
    END IF;
END //
DELIMITER ;


-- Use the database
USE InvestigationDB;

-----------------------------------------------------
-- Officers Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Officers (
    officer_id INT AUTO_INCREMENT PRIMARY KEY,
    officer_name VARCHAR(100),
    rank VARCHAR(50)
);
CREATE OR REPLACE VIEW case_evidence_details AS
SELECT c.case_id, c.case_title, e.evidence_type, e.description
FROM Cases c
JOIN Evidence e ON c.case_id = e.case_id;

DROP VIEW IF EXISTS case_evidence_details;

CREATE OR REPLACE VIEW case_evidence_details AS
SELECT c.case_id, c.case_title, e.evidence_type, e.description
FROM Cases c
JOIN Evidence e ON c.case_id = e.case_id;

DESCRIBE Evidence;





-----------------------------------------------------
-- Cases Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    case_title VARCHAR(100),
    case_status ENUM('solved','unsolved') DEFAULT 'unsolved',
    opened_date DATE,
    closed_date DATE,
    officer_id INT,
    FOREIGN KEY (officer_id) REFERENCES Officers(officer_id)
);

-----------------------------------------------------
-- Suspects Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Suspects (
    suspect_id INT AUTO_INCREMENT PRIMARY KEY,
    suspect_name VARCHAR(100),
    age INT,
    gender ENUM('Male','Female','Other')
);

-----------------------------------------------------
-- Victims Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Victims (
    victim_id INT AUTO_INCREMENT PRIMARY KEY,
    victim_name VARCHAR(100),
    age INT,
    gender ENUM('Male','Female','Other')
);

-----------------------------------------------------
-- Evidence Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Evidence (
    evidence_id INT AUTO_INCREMENT PRIMARY KEY,
    evidence_type VARCHAR(50),
    description TEXT,
    case_id INT,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);

-----------------------------------------------------
-- Witnesses Table
-----------------------------------------------------
CREATE TABLE IF NOT EXISTS Witnesses (
    witness_id INT AUTO_INCREMENT PRIMARY KEY,
    witness_name VARCHAR(100),
    statement TEXT,
    case_id INT,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);

-----------------------------------------------------
-- Minimal Views
-----------------------------------------------------
CREATE OR REPLACE VIEW case_officer_details AS
SELECT c.case_id, c.case_title, o.officer_name, c.case_status
FROM Cases c
JOIN Officers o ON c.officer_id = o.officer_id;

CREATE OR REPLACE VIEW case_evidence_details AS
SELECT c.case_id, c.case_title, e.evidence_type, e.description
FROM Cases c
JOIN Evidence e ON c.case_id = e.case_id;
CREATE OR REPLACE VIEW case_evidence_details AS
SELECT 
    c.case_id, 
    c.case_title, 
    e.description, 
    e.collected_date, 
    e.chain_of_custody
FROM Cases c
JOIN Evidence e 
    ON c.case_id = e.case_id;












