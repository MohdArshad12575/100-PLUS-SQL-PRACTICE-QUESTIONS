
-- Find the colleges where year in (2013,2017,2021) and type 'public-in-state' and no of occurance  between 6 -10.
SELECT state,
ROUND(AVG(value),1) AS avg_val, 
COUNT(*) AS no_of_occurance
FROM us_collegedata
WHERE year IN (2013,2017,2021)
AND type = 'Public In-State'
GROUP BY state
HAVING COUNT(*) BETWEEN 6 AND 10
ORDER BY avg_val
LIMIT 10;

-- 2 find the top 3 lowest fee in each state where type is public and expense is only for 'fees/tuition'

SELECT state,
MIN(value) AS totalfees
FROM us_collegedata
WHERE type LIKE 'public%'
AND expense = 'fees/tuition'
GROUP BY state
ORDER BY totalfees
LIMIT 3 ;

-- 3 top 2nd highes total fee of college where type is 'private' and year 2021 in each state

SELECT state,
SUM(value) totalfees
FROM us_collegedata
WHERE type = 'private' 
AND year = 2021
GROUP BY state
ORDER BY totalfees DESC
LIMIT 1,1;

-- 4 Retrieve all records for states that start with 'A' and have a tuition fee greater than 10,000.

 SELECT * FROM us_collegedata
 WHERE state LIKE 'a%' 
 AND Expense LIKE '%tuition'
 AND value > 10000
 ORDER BY value;
 
 -- 5  Find all records where the `Type` is either 'Private' or 'Public Out-of-State' using the `IN` clause.
 
 SELECT * FROM us_collegedata
WHERE type IN ('private','public out-of-state');

 -- 6   Get all records where the `Expense` is 'Fees/Tuition' and the `Value` is between 5,000 and 20,000.
 
 SELECT * FROM us_collegedata
 WHERE expense = 'fees/tuition'
 AND VALUE BETWEEN 5000 AND 20000;
 
 -- 7 Retrieve all records where `Length` is '4-year' and `Expense` contains the word 'Room' (use `LIKE`).
 
 SELECT * FROM us_collegedata 
 WHERE length = '4-year'
 AND expense LIKE '%room%';
 
 -- 8 Find all records where `State` contains exactly 6 letters
 
 SELECT * FROM us_collegedata
 WHERE state LIKE '______';
 
 -- 9  Retrieve the top 10 most expensive `Fees/Tuition` values, sorted in descending order.
 
 SELECT * FROM us_collegedata 
 WHERE expense = 'fees/tuition'
 ORDER BY value DESC
 LIMIT 10;
 
 -- 10 Find the 5 least expensive `Room/Board` expenses in ascending order.
 
 SELECT * FROM us_collegedata
 WHERE expense  = 'room/board'
 ORDER BY value 
 LIMIT 5;
 
  -- 11 Get the 3rd to 8th most expensive `Fees/Tuition` values using `LIMIT` and `OFFSET`.
  
  SELECT * FROM us_collegedata 
  WHERE expense = 'fees/tuition'
  ORDER BY value DESC
  LIMIT 5 OFFSET 2;
  
  -- 12  Find the total number of records for each state.
  
  SELECT state,COUNT(*) FROM us_collegedata
  GROUP BY state;
  
  -- 13 Calculate the average `Fees/Tuition` cost for each `Type` of education.
  
  SELECT type, 
  ROUND(AVG(value),2) avg_fees
  FROM us_collegedata
  WHERE expense = 'fees/tuition'
  GROUP BY type;
  
-- 14  Get the total `Room/Board` expenses for each state and filter only those states where the total is above 20,000.
  
  SELECT state, 
  SUM(value) AS total
  FROM us_collegedata
  WHERE expense = 'room/board' 
  GROUP BY state
  HAVING total > 20000;
  
-- 15 Retrieve the state with the highest total `Fees/Tuition` cost using `GROUP BY`.

  SELECT state, 
  SUM(value) AS total
  FROM us_collegedata
  WHERE expense = 'FEES/TUITION' 
  GROUP BY state
  ORDER BY total DESC;
	
-- 16  Find the total tuition fees for Public In-State colleges for 4-year programs in each state, 
--     but only include states where the total fees exceed $10,000, and display only the top 5 results

SELECT state,
SUM(value) totaltuitionfees 
FROM us_collegedata
WHERE type = "public in-state"
AND length = "4-year"
AND expense = "fees/tuition"
GROUP BY state
HAVING totaltuitionfees > 10000
ORDER BY totaltuitionfees DESC
LIMIT 5;

-- 17.	Retrieve the average room & board expenses for private colleges in each 
--      state where the average cost is greater than $8,500. Only show the top 3 states.
 
 SELECT state,
 ROUND(AVG(value),2) avgval
 FROM us_collegedata 
 WHERE expense LIKE "room%"
 AND type = "private"
 GROUP BY state
 HAVING avgval > 8500
 ORDER BY avgval DESC
 LIMIT 3;
 
 -- 18 	Find states where the total tuition cost for out-of-state public 4-year colleges 
 --     exceeds $20,000 and list them in descending order of total tuition.
 
 SELECT state,
 SUM(value) totalcost
 FROM us_collegedata
 WHERE expense LIKE "fees%"
 AND length LIKE "4%"
 GROUP BY state
 HAVING totalcost > 20000
 ORDER BY totalcost DESC;
 
 -- 19.	List the top 5 states with the highest average tuition 
 --     fee for private 4-year colleges where the average fee is greater than $15,000.
 
 SELECT state,
 ROUND(AVG(value),2) avgtuitionfee
 FROM us_collegedata
 WHERE length LIKE "4%"
 AND type LIKE "private%"
 GROUP BY state 
 HAVING avgtuitionfee > 15000
 ORDER BY avgtuitionfee DESC
 LIMIT 5;
 
 -- 20   Find the top 3 states with the highest total expenses (tuition + room & board) 
 --      for public in-state 4-year colleges where the total exceeds $15,000.
 
 SELECT state,
 SUM(value) totalexpense 
 FROM us_collegedata
 WHERE type = "public in-state"
 AND length LIKE "4%"
 GROUP BY state
 HAVING totalexpense > 15000
 ORDER BY totalexpense DESC
 LIMIT 3 ;
 
 -- 21  Find states where the tuition fee for 2-year public in-state colleges is 
 --      greater than $4,000 and display only the top 5 in descending order
 
 SELECT state,
 SUM(value)
 FROM us_collegedata 
 WHERE length LIKE "2%" 
 AND type = "public in-state"
 GROUP BY state 
 HAVING  SUM(value) > 4000
 ORDER BY  SUM(value) DESC
 LIMIT 5;
 
 
 -- 22  Get the top 5 states where the combined tuition fee for public and private 
 --     colleges is highest, filtering out states where the total is below $25,000.
 
 SELECT state,
 SUM(value) totalfees
 FROM us_collegedata
 WHERE expense LIKE "fees%"
 GROUP BY state 
 HAVING totalfees > 25000
 ORDER BY totalfees DESC
 LIMIT 5;
 
 -- 23  Find states where the room & board expenses for public out-of-state 4-year 
 --     colleges exceed $8,000, and display them in descending order.
 
 SELECT state,
 SUM(value) fee
 FROM us_collegedata
 WHERE expense LIKE "room%"
 AND type = "public out-of-state"
 AND length LIKE "4%"
 GROUP BY state
 HAVING fee > 8000
 ORDER BY fee DESC ;
 
 -- 24  List the top 3 states with the highest average tuition fees for public in-state 
 --     and public out-of-state 4-year colleges, where the average fee is above $10,000.
 
 SELECT state,
 ROUND(AVG(value),2) avgfee
 FROM us_collegedata
 WHERE type LIKE "public%"
 GROUP BY state
 HAVING avgfee > 10000
 ORDER BY avgfee DESC 
 LIMIT 3;
 
 -- 25  Find states where the total expenses (tuition + room & board) for all 4-year colleges 
 --     (public and private) exceed $30,000, displaying the top 5 in descending order.
 
 SELECT state,
 SUM(value) totalfee
 FROM us_collegedata
 WHERE length LIKE "4%"
 GROUP BY state
 HAVING totalfee > 30000
 ORDER BY totalfee DESC
 LIMIT 5;
 
 
 
 




