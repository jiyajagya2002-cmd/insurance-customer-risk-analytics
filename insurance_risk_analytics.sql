CREATE DATABASE insurance_risk_analytics;
USE insurance_risk_analytics;
SELECT COUNT(*) AS total_rows
FROM insurance_customers;
DESCRIBE insurance_customers;

SELECT * FROM insurance_customers LIMIT 10;

# CUSTOMER PROFILE
--How is the customer base distributed by gender?
SELECT Gender, COUNT(*) AS customer_count FROM insurance_customers GROUP BY Gender ORDER BY customer_count DESC;

--What is the distribution of customers by marital status?
SELECT `Marital Status`, COUNT(*) AS customer_count FROM insurance_customers GROUP BY `Marital Status` ORDER BY customer_count DESC;

--Which occupations have the largest customer base?
SELECT Occupation, COUNT(*) AS customer_count FROM insurance_customers GROUP BY Occupation ORDER BY customer_count DESC;

--What is the distribution of customers across different education levels?
SELECT `Education Level`, COUNT(*) AS customer_count FROM insurance_customers GROUP BY `Education Level`ORDER BY customer_count DESC;

--How are customers distributed across income levels?
SELECT 
    MIN(`Income Level`) AS minimum_income,
    MAX(`Income Level`) AS maximum_income,
    AVG(`Income Level`) AS average_income
FROM insurance_customers;

--How are customers distributed across different income ranges?
SELECT
    CASE
        WHEN `Income Level` < 25000 THEN 'Below 25K'
        WHEN `Income Level` < 50000 THEN '25K-50K'
        WHEN `Income Level` < 75000 THEN '50K-75K'
        WHEN `Income Level` < 100000 THEN '75K-100K'
        ELSE '100K+'
    END AS income_range,
    COUNT(*) AS customer_count FROM insurance_customers GROUP BY income_range ORDER BY customer_count DESC;
    
--How are customers distributed across geographic regions?
SELECT 
    `Geographic Information`,
    COUNT(*) AS customer_count
FROM insurance_customers GROUP BY `Geographic Information` ORDER BY customer_count DESC;

--How are customers distributed across age groups?
SELECT 
    `Age Group`,
    COUNT(*) AS customer_count
FROM insurance_customers GROUP BY `Age Group` ORDER BY customer_count DESC;

#POLICY & PREMIUM ANALYSIS
--Which age groups tend to have which types of insurance policies?
SELECT `Age Group`,`Policy Type`,COUNT(*) AS customer_count
FROM insurance_customers GROUP BY `Age Group`, `Policy Type` ORDER BY `Age Group`, customer_count DESC;

--Do customers with different driving records have different previous-claims histories?
SELECT `Driving Record`,`Previous Claims History`,COUNT(*) AS customer_count
FROM insurance_customers GROUP BY `Driving Record`, `Previous Claims History` ORDER BY `Driving Record`, `Previous Claims History`;

--Do customers with more previous claims pay higher average premiums?
SELECT `Previous Claims History`,COUNT(*) AS customer_count,AVG(`Premium Amount`) AS average_premium
FROM insurance_customers GROUP BY `Previous Claims History` ORDER BY `Previous Claims History`;

--Do customers in different income ranges tend to have different types of insurance policies?
SELECT
    CASE
        WHEN `Income Level` < 25000 THEN 'Below 25K'
        WHEN `Income Level` < 50000 THEN '25K-50K'
        WHEN `Income Level` < 75000 THEN '50K-75K'
        WHEN `Income Level` < 100000 THEN '75K-100K'
        ELSE '100K+'
    END AS income_range,
    `Policy Type`,COUNT(*) AS customer_count
FROM insurance_customers GROUP BY income_range, `Policy Type` ORDER BY income_range, customer_count DESC;

--Which policy types generate the most premium and coverage?
SELECT
    `Policy Type`,
    COUNT(*) AS customer_count,
    SUM(`Premium Amount`) AS total_premium,
    AVG(`Premium Amount`) AS average_premium,
    SUM(`Coverage Amount`) AS total_coverage,
    AVG(`Coverage Amount`) AS average_coverage
FROM insurance_customers
GROUP BY `Policy Type`
ORDER BY total_premium DESC;

--How does average premium vary across credit-score bands?
SELECT
    CASE
        WHEN `Credit Score` < 600 THEN 'Below 600'
        WHEN `Credit Score` < 700 THEN '600-699'
        WHEN `Credit Score` < 750 THEN '700-749'
        WHEN `Credit Score` < 800 THEN '750-799'
        ELSE '800+'
    END AS credit_score_band,
    COUNT(*) AS customer_count,
    AVG(`Premium Amount`) AS average_premium
FROM insurance_customers GROUP BY credit_score_band ORDER BY average_premium DESC;

--Do customers with different driving records have different average premiums?
SELECT
    `Driving Record`,
    COUNT(*) AS customer_count, AVG(`Premium Amount`) AS average_premium, AVG(`Coverage Amount`) AS average_coverage
FROM insurance_customers GROUP BY `Driving Record` ORDER BY average_premium DESC;

--How many customers pay a premium above the overall average?
SELECT
    COUNT(*) AS customers_above_average
FROM insurance_customers WHERE `Premium Amount` >
      (SELECT AVG(`Premium Amount`) FROM insurance_customers);

--Which policy types have an average premium higher than the overall average premium?      
SELECT
    `Policy Type`,
    AVG(`Premium Amount`) AS average_premium
FROM insurance_customers GROUP BY `Policy Type` HAVING AVG(`Premium Amount`) >
(SELECT AVG(`Premium Amount`) FROM insurance_customers);

--How do policy types rank based on total premium generated?
SELECT
    `Policy Type`,
    SUM(`Premium Amount`) AS total_premium,
    RANK() OVER (ORDER BY SUM(`Premium Amount`) DESC) AS premium_rank
FROM insurance_customers GROUP BY `Policy Type`;

--How do age groups rank based on their average premium?
SELECT
    `Age Group`,
    AVG(`Premium Amount`) AS average_premium,
    RANK() OVER (ORDER BY AVG(`Premium Amount`) DESC) AS premium_rank
FROM insurance_customers GROUP BY `Age Group`;

--Within each age group, how do policy types rank by average premium?
SELECT
    `Age Group`,
    `Policy Type`,
    AVG(`Premium Amount`) AS average_premium,
    RANK() OVER (PARTITION BY `Age Group`ORDER BY AVG(`Premium Amount`) DESC) AS premium_rank
FROM insurance_customers GROUP BY `Age Group`, `Policy Type`;

--Which policy types generate the highest total premium, and what is their rank?
SELECT
    `Policy Type`,SUM(`Premium Amount`) AS total_premium,RANK() OVER (
        ORDER BY SUM(`Premium Amount`) DESC) AS premium_rank
FROM insurance_customers GROUP BY `Policy Type`;

--Within each age group, which policy types have the highest average premium?
SELECT
    `Age Group`,
    `Policy Type`,
    AVG(`Premium Amount`) AS average_premium,
    RANK() OVER (PARTITION BY `Age Group` ORDER BY AVG(`Premium Amount`) DESC) AS premium_rank
FROM insurance_customers GROUP BY `Age Group`, `Policy Type` ORDER BY `Age Group`, premium_rank;

--How many customers have a premium above the overall average premium?
WITH average_premium AS (SELECT AVG(`Premium Amount`) AS avg_premium FROM insurance_customers)
SELECT COUNT(*) AS customers_above_average
FROM insurance_customers WHERE `Premium Amount` > (SELECT avg_premium FROM average_premium);

--For each policy type, what are the customer count, total premium, and average premium?
WITH policy_metrics AS (SELECT `Policy Type`, COUNT(*) AS customer_count,SUM(`Premium Amount`) AS total_premium,AVG(`Premium Amount`) AS average_premium
FROM insurance_customers GROUP BY `Policy Type`)
SELECT * FROM policy_metrics ORDER BY total_premium DESC;

--What is the average premium for each age group, along with the number of customers?
WITH age_premium AS (SELECT `Age Group`, COUNT(*) AS customer_count,AVG(`Premium Amount`) AS average_premium 
FROM insurance_customers GROUP BY `Age Group`) SELECT `Age Group`,customer_count,average_premium FROM age_premium ORDER BY average_premium DESC;