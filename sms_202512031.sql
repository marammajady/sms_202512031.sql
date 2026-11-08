
PART A:



CREATE TABLE ranks (
    rank_id SERIAL PRIMARY KEY,
    rank_name VARCHAR(100) NOT NULL UNIQUE,
    rank_level INT CHECK (rank_level BETWEEN 1 AND 6) NOT NULL
);

CREATE TABLE units (
    unit_id SERIAL PRIMARY KEY,
    unit_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL
);

CREATE TABLE missions (
    mission_id SERIAL PRIMARY KEY,
    mission_name VARCHAR(100) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT check_end_date CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE soldiers (
    soldier_id SERIAL PRIMARY KEY,
    service_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    enlistment_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'On Leave', 'Retired')) NOT NULL,
    rank_id INT NOT NULL REFERENCES ranks(rank_id),
    unit_id INT NOT NULL REFERENCES units(unit_id),
    CONSTRAINT check_dates CHECK (enlistment_date > date_of_birth)
);

CREATE TABLE soldier_missions (
    soldier_id INT REFERENCES soldiers(soldier_id),
    mission_id INT REFERENCES missions(mission_id),
    mission_role VARCHAR(100) NOT NULL,
    PRIMARY KEY (soldier_id, mission_id)
);  

PART B:



INSERT INTO ranks (rank_id, rank_name, rank_level) VALUES
(1, 'Private', 1),
(2, 'Corporal', 2),
(3, 'Sergeant', 3),
(4, 'Lieutenant', 4),
(5, 'Captain', 5),
(6, 'Major', 6);

INSERT INTO units (unit_id, unit_name, location) VALUES
(1, 'Alpha Company', 'North Camp'),
(2, 'Bravo Company', 'South Camp'),
(3, 'Charlie Company', 'East Camp'),
(4, 'Delta Company', 'West Camp'),
(5, 'Signals Unit', 'Central Camp'),
(6, 'Medical Unit', 'Central Camp');

INSERT INTO missions (mission_id, mission_name, start_date, end_date) VALUES
(1, 'Exercise Falcon', '2025-02-03', '2025-02-28'),
(2, 'Flood Relief', '2025-04-14', '2025-05-30'),
(3, 'Border Patrol', '2025-07-01', NULL),
(4, 'Peace Support', '2025-09-15', NULL),
(5, 'Field Medical Camp', '2026-01-12', '2026-01-23');

INSERT INTO soldiers (soldier_id, service_number, first_name, last_name, date_of_birth, enlistment_date, status, rank_id, unit_id) VALUES
(31, 'ST-202512031', 'Muram', 'Magdi', '2000-01-01', '2020-01-01', 'Active', 1, 2),
(32, 'ST-202512031-2', 'Douaa', 'Abdurhman', '2001-02-02', '2021-02-02', 'Active', 1, 2),
(33, 'ST-202512031-3', 'Awrad', 'Mohamed', '2002-03-03', '2022-03-03', 'Active', 2, 2);

INSERT INTO soldier_missions (soldier_id, mission_id, mission_role) VALUES
(31, 2, 'Scout'),
(32, 2, 'Medic');

PART C:

SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10;

SELECT * FROM (SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10) AS sub ORDER BY soldier_id ASC;

SELECT * FROM soldiers WHERE soldier_id IN (10, 15, 20);

SELECT * FROM soldiers WHERE soldier_id IN (10 + 1, 15 + 1, 20 + 1);

SELECT * FROM soldiers WHERE status = 'Active' AND soldier_id BETWEEN 10 AND 20;

SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name FROM soldiers s JOIN ranks r ON s.rank_id = r.rank_id ORDER BY r.rank_level DESC, s.last_name ASC;

SELECT s.first_name, s.last_name, r.rank_name, u.unit_name, u.location FROM soldiers s JOIN ranks r ON s.rank_id = r.rank_id JOIN units u ON s.unit_id = u.unit_id WHERE s.status = 'Active' AND u.unit_id = 2;

SELECT m.mission_name, CONCAT(s.first_name, ' ', s.last_name) AS soldier_name, sm.mission_role, u.unit_name FROM soldier_missions sm JOIN missions m ON sm.mission_id = m.mission_id JOIN soldiers s ON sm.soldier_id = s.soldier_id JOIN units u ON s.unit_id = u.unit_id WHERE m.mission_id = 2;

SELECT * FROM soldiers WHERE soldier_id NOT IN (SELECT soldier_id FROM soldier_missions);

SELECT u.unit_name, COUNT(s.soldier_id) AS soldier_count FROM units u LEFT JOIN soldiers s ON u.unit_id = s.unit_id GROUP BY u.unit_id, u.unit_name ORDER BY soldier_count DESC;


PART D:

EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';

CREATE INDEX idx_soldiers_last_name ON soldiers(last_name);

EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';

CREATE VIEW v_soldier_profile AS
SELECT s.soldier_id, CONCAT(s.first_name, ' ', s.last_name) AS full_name, r.rank_name, u.unit_name, u.location, s.status
FROM soldiers s
JOIN ranks r ON s.rank_id = r.rank_id
JOIN units u ON s.unit_id = u.unit_id;

SELECT * FROM v_soldier_profile WHERE unit_name = (SELECT unit_name FROM units WHERE unit_id = 2) ORDER BY full_name;


