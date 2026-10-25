# Task 1
CREATE SCHEMA pandemic;
USE pandemic;

SELECT COUNT(*) FROM infectious_cases;

# Task 2
CREATE TABLE countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(10)
);

INSERT INTO  countries (country_name, country_code)
SELECT DISTINCT Entity, Code FROM infectious_cases;

CREATE TABLE cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    country_id INT,
    year YEAR,
    number_yaws VARCHAR(25),
    polio_cases INT,
    cases_guinea_worm INT,
    number_rabies VARCHAR(25),
    number_malaria VARCHAR(25),
    number_hiv VARCHAR(25),
    number_tuberculosis VARCHAR(25),
    number_smallpox VARCHAR(25),
    number_cholera_cases VARCHAR(25),
	FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

INSERT INTO  cases (country_id,
    year,
    number_yaws ,
    polio_cases,
    cases_guinea_worm,
    number_rabies,
    number_malaria,
    number_hiv,
    number_tuberculosis,
    number_smallpox,
    number_cholera_cases)
SELECT countries.country_id,
	   ic.year,
	   ic.Number_yaws,
       ic.polio_cases,
       ic.cases_guinea_worm,
       ic.Number_rabies,
       ic.Number_malaria,
       ic.Number_hiv,
       ic.Number_tuberculosis,
       ic.Number_smallpox,
       ic.Number_cholera_cases
FROM infectious_cases as ic
JOIN countries ON countries.country_code = ic.Code;

# Checks if all the rows from infectious_cases table are transfered to the cases table
SELECT (SELECT COUNT(*) FROM cases) = (SELECT COUNT(*) FROM infectious_cases);

# Task 3
SELECT countries.country_name,
       countries.country_code,
       AVG(cases.number_rabies) as number_rabies_avg,
       MIN(cases.number_rabies) as number_rabies_min,
       MAX(cases.number_rabies) as number_rabies_max,
       SUM(cases.number_rabies) as number_rabies_sum
FROM countries
JOIN cases ON countries.country_id = cases.country_id
WHERE cases.number_rabies != ''
GROUP BY countries.country_name, countries.country_code
ORDER BY number_rabies_avg DESC
LIMIT 10;

# Task 4
SELECT first_day_in_year,
       today_date,
       TIMESTAMPDIFF(YEAR, first_day_in_year, today_date) as difference
FROM (SELECT MAKEDATE(year, 1) as first_day_in_year,
             CURDATE() as today_date 
             FROM cases) AS dates;

# Task 5
# Function 1
DELIMITER //

CREATE FUNCTION Calculate_year_diff(start_year YEAR)
RETURNS INT
NO SQL
BEGIN
    DECLARE result INT;
    DECLARE start_date DATE;
    DECLARE curr_date DATE;
    
    SET start_date = MAKEDATE(start_year, 1);
    SET curr_date = CURDATE();
    SET result = TIMESTAMPDIFF(YEAR, start_date, curr_date);
    
    RETURN result;
END //

DELIMITER ;

SELECT Calculate_year_diff(year)
FROM cases;

# Function 2
DROP FUNCTION IF EXISTS Calculate_average_cases;
DELIMITER //

CREATE FUNCTION Calculate_average_cases(cases_per_year VARCHAR(150), divider INT)
RETURNS DECIMAL
NO SQL
BEGIN
    DECLARE result DECIMAL;
    
	IF divider NOT IN (12, 4, 2) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Divider must be 12, 4, or 2';
    END IF;
    
    SET result = cases_per_year / divider;
    RETURN result;
END //

DELIMITER ;

SELECT number_yaws as yearly_number_yaws,
       Calculate_average_cases(number_yaws, 12) as monthly_number_yaws
FROM cases
WHERE number_yaws != ''
