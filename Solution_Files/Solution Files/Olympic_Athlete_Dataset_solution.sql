-- 1. Display the names of athletes who won a gold medal in the 2008 Olympics and whose height is 
-- greater than the average height of all athletes in the 2008 Olympics.

SELECT name,medal,height 
FROM olympic_athletes 
WHERE medal = "Gold"
AND height > (SELECT AVG(height) 
              FROM olympic_athletes 
              WHERE year = 2000);

-- 2. Display the names of athletes who won a medal in the sport of basketball in the 
-- 2016 Olympics and whose weight is less than the average weight of all athletes 
-- who won a medal in the 2016 Olympics.

SELECT name,medal,sport
FROM olympic_athletes 
WHERE Year = 2016
AND sport = 'basketball'
AND medal IS NOT NULL
AND weight < (SELECT AVG(weight) 
              FROM olympic_athletes 
              WHERE year = 2016
              AND medal IS NOT NULL);
              
-- 3. Display the names of all athletes who have won a medal in the sport of swimming in both the 
-- 2008 and 2016 Olympics.

SELECT name , medal,Year
FROM olympic_athletes
WHERE year IN (2008,2016)
AND sport = 'swimming'
AND medal IS NOT NULL;

-- 4 Display the names of all countries that have won more than 50 medals in a single year.

SELECT country,year,
COUNT(*) 
FROM olympic_athletes
WHERE medal IS NOT NULL
GROUP BY country,year 
HAVING COUNT(*) > 50;

-- 5 Display the names of all athletes who have won medals in more than 
-- one sport in the same year.

SELECT name,year,
COUNT(*)
FROM olympic_athletes
WHERE medal IS NOT NULL
GROUP BY name,year
HAVING COUNT(*) > 2 ;

--                          BY USING WINDOW FUNCTION 

-- 1.. Running Total of Athletes Over Time
-- Retrieve the cumulative number of unique athletes who have participated in the Olympics over the years.

SELECT year,
COUNT(DISTINCT name) Unique_athletes_count,
SUM(COUNT(DISTINCT name)) OVER(ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 'cummalative number of unique athetes'
FROM olympic_athletes
GROUP BY year;

-- 2. Rank Athletes by Appearances
-- Rank athletes by the number of Olympic appearances they have made.

SELECT name,
COUNT(DISTINCT games) 'olympic appearance count',
DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT games) DESC) 'rank'
FROM olympic_athletes
GROUP BY name;

-- 3. First and Last Year of Participation
-- Find the first and last year each athlete participated.
         
                               -- WITH WINDOW FUNCTION 
SELECT * FROM (SELECT name,
               FIRST_VALUE(year) OVER(PARTITION BY name ORDER BY year ) first_year,
               LAST_VALUE(year)  OVER(PARTITION BY name ORDER BY year 
                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) last_year,
			   DENSE_RANK() OVER(PARTITION BY name ORDER BY year) ranks
			   FROM olympic_athletes) t
WHERE t.ranks = 1;

                                         -- WITHOUT WINDOW FUCNTION
SELECT Name, 
       MIN(Year) AS first_appearance, 
       MAX(Year) AS last_appearance
FROM olympic_athletes
GROUP BY Name;

-- 4. Find the Heaviest Athlete per Year
--    Find the heaviest athlete in each Olympic year.

SELECT Year, Name, Weight
FROM (
    SELECT Year, Name, Weight, 
           RANK() OVER (PARTITION BY Year ORDER BY Weight DESC) AS rnk
    FROM olympic_athletes
    WHERE Weight IS NOT NULL
) ranked
WHERE rnk = 1;


-- 5. Show the total number of medals won by each country.

SELECT country,
COUNT(*) medalswon
FROM olympic_athletes
WHERE medal IS NOT NULL
GROUP BY country;

-- 6 Find the youngest athlete to win a medal in each sport.

SELECT * FROM (SELECT sport,age,medal,
               ROW_NUMBER() OVER(PARTITION BY sport ORDER BY age) ranks
			   FROM olympic_athletes
               WHERE medal IS NOT NULL
               AND age IS NOT NULL) t
WHERE t.ranks = 1;

-- 8. Find athletes who have participated in at least two Olympics.

SELECT name,
COUNT(event) ParticipatedCount
FROM olympic_athletes
GROUP BY name
HAVING ParticipatedCount > 2;

-- 9. Most Common Sport for Each Country
--   Find the most common sport each country has participated in.

SELECT * FROM (SELECT country,sport,
			   COUNT(*) numberoftimesparticipate,
               RANK() OVER(PARTITION BY country,sport ORDER BY COUNT(*) DESC ) ranking
               FROM olympic_athletes
               GROUP BY country,sport) t
WHERE t.ranking = 1
ORDER BY t.numberoftimesparticipate DESC;

-- 10. Find Athletes Who Changed Sports
-- Find athletes who have competed in more than one sport.

SELECT Name, COUNT(DISTINCT Sport) AS sport_count
FROM olympic_athletes
GROUP BY Name
HAVING COUNT(DISTINCT Sport) > 1;

