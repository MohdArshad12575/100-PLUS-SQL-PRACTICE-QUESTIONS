SELECT * FROM insurancedb.health_insurance;


-- 1. Retrieve the details of the youngest patient(s) in the dataset.

SELECT * FROM health_insurance WHERE 
age = (SELECT MIN(age) FROM health_insurance);

-- 2. How many patients have claimed more than the average claim amount for patients who are smokers and have at least one 
-- child, and belong to the southeast region?


SELECT COUNT(claim) FROM health_insurance
WHERE claim > ( SELECT CEIL(AVG(claim))
                FROM health_insurance
                WHERE smoker ='yes'
                AND children > 0
                AND region = 'southeast');
                
-- 3. How many patients have claimed more than the average claim amount for patients who are
-- not smokers and have a BMI greater than the average BMI for patients who have at least one child?


SELECT COUNT(*) FROM health_insurance
WHERE claim > ( SELECT CEIL(AVG(claim)) FROM health_insurance
				WHERE smoker = 'no'
                AND bmi > (SELECT CEIL(AVG(bmi)) FROM health_insurance
                           WHERE children > 0 ) );

-- 4. How many patients have claimed more than the average claim amount for patients 
-- who have a BMI greater than the average BMI for patients who are diabetic, 
-- have at least one child, and are from the southwest region?

SELECT COUNT(*) FROM health_insurance
WHERE claim > ( SELECT CEIL(AVG(claim)) FROM health_insurance
				WHERE smoker = 'no'
                AND bmi > (SELECT CEIL(AVG(bmi)) FROM health_insurance
                           WHERE children > 0
                           AND diabetic = 'yes'
                           AND region = 'southwest') );


-- 5. What is the difference in the average claim amount between patients who are smokers and patients who are non-smokers, 
-- and have the same BMI and number of children?

SELECT (AVG(a.claim) - AVG(b.claim)) FROM health_insurance A
JOIN health_insurance B
ON a.bmi = b.bmi
AND a.children = b.children
AND a.smoker != b.smoker;

-- 6.Find patients whose claim amount is higher than the average claim amount of their 
-- respective region (using a correlated subquery).


SELECT * FROM health_insurance h1
WHERE claim > (SELECT AVG(claim) 
               FROM health_insurance h2
               WHERE h2.region = h1.region);
               
-- 7.List patients whose BMI is higher than the average BMI of people in their 
-- age group (using a correlated subquery).

SELECT * FROM health_insurance h1
WHERE bmi > (SELECT AVG(bmi) 
               FROM health_insurance h2
               WHERE h2.age != h1.age);

                          -- TRY TO SOLVE USING WINDOW FUNCTION 
                          
-- 8.What are the top 5 patients who claimed the highest insurance amounts?

SELECT * FROM (SELECT patientid,
ROUND(SUM(claim)),
DENSE_RANK() OVER(ORDER BY ROUND(SUM(claim)) DESC) ranking
FROM health_insurance
GROUP BY patientid)t
WHERE t.ranking < 6;

                              -- YOU CAN ALSO USE LIMIT CLAUSE HERE 
SELECT patientid,
ROUND(SUM(claim))
FROM health_insurance
GROUP BY patientid
ORDER BY ROUND(SUM(claim)) DESC
LIMIT 5;

-- 9. What is the average insurance claimed by patients based on the number of children they have?

SELECT t.children,t.avg_claim FROM (SELECT children,
AVG(claim) OVER(PARTITION BY children) avg_claim,
ROW_NUMBER() OVER(PARTITION BY children) ranking 
FROM health_insurance) t
WHERE t.ranking < 2 ;

-- 10. What is the highest and lowest claimed amount by patients in each region?

SELECT * FROM (SELECT region,
FIRST_VALUE(claim) OVER(PARTITION BY region  ORDER BY claim DESC) highest_value ,
LAST_VALUE(claim) OVER(PARTITION BY region  ORDER BY claim DESC 
					   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) lowest_value ,
ROW_NUMBER() OVER(PARTITION BY region) ranking
FROM health_insurance )t
WHERE t.ranking < 2;

-- 11. What is the difference between the claimed amount of each 
-- patient and the claimed amount of first patient?

SELECT *,
ROUND((claim - FIRST_VALUE(claim) OVER()),2) difference
FROM health_insurance;

-- 12. For each patient, calculate the difference between their claimed amount and the average claimed 
-- amount of patients with the same number of children.

SELECT *, 
ROUND(claim - AVG(claim) OVER(PARTITION BY children),2) difference
FROM health_insurance;

-- 13. Show the patient with the highest BMI in each region and their respective rank.

SELECT * FROM(SELECT *,
MAX(bmi) OVER(PARTITION BY region ORDER BY bmi DESC) highest_bmi,
DENSE_RANK() OVER() ranking
FROM health_insurance) t
WHERE t.ranking = 1;

-- 14. Calculate the difference between the claimed amount of each patient and the claimed amount of 
-- the patient who has the highest BMI in their region.

SELECT *,
MAX(bmi) OVER(PARTITION BY region ORDER BY bmi DESC)  highest_bmi,
ROUND(claim - FIRST_VALUE(claim) OVER(PARTITION BY region),2) claimedval
FROM health_insurance;

-- 15. For each patient, calculate the difference in claim amount between the patient and the patient 
-- with the highest claim amount among patients with the same smoker status, 
-- within the same region. Return the result in descending order difference.

SELECT *,
MAX(claim) OVER(PARTITION BY smoker,region) 'max claim same bmi and smoker status',
(claim - MAX(claim) OVER(PARTITION BY smoker,region)) difference
FROM health_insurance;

-- 16. For each patient, find the maximum BMI value among their next three records (ordered by age).

SELECT *,
MAX(bmi) OVER(ROWS BETWEEN 0 PRECEDING AND 3 FOLLOWING ) 'max bmi frame 3 following '
FROM health_insurance
ORDER BY age;

-- 17. For each patient, find the rolling average of the last 2 claims.

SELECT *,
AVG(claim) OVER(ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) ' avg claim frame 2 preceding'
FROM health_insurance;


-- 18.Find the first claimed insurance value for male and female patients, within each region order the data 
-- by patient age in ascending order, and only include patients who are non-diabetic and have a bmi value between 25 and 30.

	WITH filtered_data AS (
    SELECT * FROM health_insurance
    WHERE diabetic = 'no'
    AND bmi BETWEEN 25 AND 30
    ) 
SELECT * FROM (SELECT *,
               FIRST_VALUE(claim) OVER(PARTITION BY gender,region ORDER BY age) firstclaim,
               ROW_NUMBER() OVER(PARTITION BY region,gender ORDER BY age) ranking
               FROM health_insurance) t
               WHERE t.ranking = 1
    



