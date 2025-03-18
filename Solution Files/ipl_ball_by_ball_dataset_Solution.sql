SELECT * FROM campusx.iplballdata;
-- 1. Total Runs Scored in Each Match and Innings

SELECT id,
innings,
SUM(total_run)
FROM iplballdata
GROUP BY id,innings;

-- 2. Top 5 Batters with Highest Strike Rate (Min 20 Balls Faced)

SELECT *,
(t.totalrun/t.noofballfaced)*100 strikeRate
FROM (SELECT 
      batter,
	  SUM(batsman_run) totalrun,
      COUNT(batsman_run) noofballfaced
      FROM iplballdata
      GROUP BY batter
      ORDER BY SUM(batsman_run) DESC) t
LIMIT 5;

-- 3. Bowlers with More Than 3 Wickets in an Innings

SELECT id,innings,
bowler,
COUNT(iswicketdelivery) wicketcount
FROM iplballdata
WHERE iswicketdelivery = 1
GROUP BY id,innings,bowler
HAVING COUNT(iswicketdelivery) > 3
ORDER BY COUNT(iswicketdelivery) DESC;

-- 4. Total Extras Conceded by Each Team in a Match

SELECT id,battingteam,
SUM(extras_run) total_extras
FROM iplballdata
GROUP BY id,battingteam;

-- 5.Find the Over with Most Runs Scored in Each Match

SELECT id,innings,overs,
SUM(total_run) total_score_in_over
FROM iplballdata
GROUP BY id,innings,overs
ORDER BY SUM(total_run) DESC ;

-- 6.Instances Where 6+ Runs Were Scored in Consecutive Balls

SELECT id,innings,overs,ballnumber,batter,total_run FROM iplballdata
WHERE total_run >= 6
ORDER BY id,innings,overs,ballnumber;

-- 7.Total Dot Balls Bowled by Each Bowler

SELECT bowler,
COUNT(total_run) totalballs
FROM iplballdata
WHERE total_run = 0
GROUP BY bowler
ORDER BY COUNT(total_run) DESC;

-- 8.Rank Batters by Total Runs in Each Match

SELECT CONCAT("Match-",ROW_NUMBER() OVER(PARTITION BY id)) matchno,
batter,
SUM(batsman_run) total_run
FROM iplballdata
GROUP BY id,batter
ORDER BY SUM(batsman_run) DESC;

-- 9.Find the Next Bowler After a Specific Bowler Using LEAD()

SELECT ID, innings, overs, bowler,
LEAD(bowler) OVER (PARTITION BY ID, innings ORDER BY overs, ballnumber) AS next_bowler
FROM iplballdata;

-- 10.Difference in Runs Scored Between Current and Previous Over Using LAG()

SELECT *,
(t.Runs_Scored - t.previousoverrun) Difference
FROM 
(SELECT id,innings,overs,bowler,
SUM(total_run) Runs_Scored,
LAG(SUM(total_run)) OVER() previousoverrun
FROM iplballdata
GROUP BY id,innings,overs,bowler) t;

-- 11.3th Highest Run-Scorer in an Innings Using NTH_VALUE()

SELECT id,innings,battingteam,
SUM(total_run) total_runs,
NTH_VALUE(battingteam,3)  OVER(ORDER BY SUM(total_run) DESC) third_highest_scorer_team
FROM iplballdata
GROUP BY id,innings,battingteam
ORDER BY SUM(total_run) DESC;

-- 12.Running Total of Runs for Each Team in a Match

SELECT *,
SUM(t.runs_each_ball) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_total_runs
FROM  (SELECT id,battingteam,overs,ballnumber,
	   SUM(total_run) runs_each_ball
       FROM iplballdata
       GROUP BY id,battingteam,overs,ballnumber)t;
       

       








