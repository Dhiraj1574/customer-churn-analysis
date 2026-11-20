-- Customer churn analysis (Telco dataset, MySQL)

-- 1. Check the row count (expected 7043)
SELECT COUNT(*) FROM churn_project.telco_churn;

-- 2. Churn split (Yes/No)
SELECT Churn, COUNT(*) AS customers FROM churn_project.telco_churn GROUP BY Churn;

-- 3. Cleaning: count blank TotalCharges values (expected 11)
SELECT COUNT(*) FROM churn_project.telco_churn WHERE TRIM(TotalCharges) = '';

-- 4. Cleaning: turn blanks into NULL (run once; needs safe update mode off)
SET SQL_SAFE_UPDATES = 0;
UPDATE churn_project.telco_churn SET TotalCharges = NULL WHERE TRIM(TotalCharges) = '';

-- 5. Cleaning: convert TotalCharges to a decimal (run once)
ALTER TABLE churn_project.telco_churn MODIFY TotalCharges DECIMAL(10,2);

-- 6. Churn rate by contract type
SELECT Contract,
       COUNT(*) AS customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
       ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_rate_pct
FROM churn_project.telco_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- 7. Churn rate by tenure group
SELECT CASE
         WHEN tenure <= 12 THEN '0-12 months'
         WHEN tenure <= 24 THEN '13-24 months'
         ELSE '25+ months'
       END AS tenure_group,
       COUNT(*) AS customers,
       ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_rate_pct
FROM churn_project.telco_churn
GROUP BY tenure_group
ORDER BY churn_rate_pct DESC;

-- 8. Churn rate by monthly charges
SELECT CASE
         WHEN MonthlyCharges < 35 THEN 'Under $35'
         WHEN MonthlyCharges < 70 THEN '$35 to $70'
         ELSE 'Over $70'
       END AS charge_band,
       COUNT(*) AS customers,
       ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS churn_rate_pct
FROM churn_project.telco_churn
GROUP BY charge_band
ORDER BY churn_rate_pct DESC;