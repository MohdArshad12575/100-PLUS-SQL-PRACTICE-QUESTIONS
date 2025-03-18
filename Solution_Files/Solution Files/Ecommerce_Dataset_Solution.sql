-- 1. Rank employees by revenue generation

SELECT *,
DENSE_RANK() OVER(ORDER BY t.revenue DESC) ranking
FROM (SELECT e.employeeid,e.lastname,
ROUND(SUM(od.unitprice * od.quantity)) revenue
FROM employees e 
JOIN orders o
ON o.employeeid = e.employeeid
JOIN order_details od
ON od.orderid = o.orderid
GROUP BY e.employeeid,e.lastname ) t;

-- 2. Rank products based on total sales amount

SELECT *,
DENSE_RANK() OVER(ORDER BY t.revenue DESC) ranks
FROM (SELECT p.productid,p.productname,
ROUND(SUM(od.unitprice * od.quantity)) revenue
FROM products p
JOIN order_details od
ON p.productid = od.productid
GROUP BY p.productid,p.productname) t;

-- 3. Find the top 5 customers contributing the most revenue

SELECT o.customerid,
ROUND(SUM(od.unitprice * od.quantity)) Revenue 
FROM orders o
JOIN order_details od
ON o.orderid = od.orderid
GROUP BY o.customerid
ORDER BY Revenue DESC
LIMIT 5;

-- 4. Show the running total of revenue for each employee over time Month And Year

SELECT e.employeeid,e.firstname,
MONTHNAME(o.orderdate) month,
YEAR(o.orderdate) year,
ROUND(SUM(od.unitprice * od.quantity)) revenue,
ROUND(SUM(SUM(od.unitprice * od.quantity))
OVER(PARTITION BY e.employeeid,e.firstname,YEAR(o.orderdate)
     ORDER BY YEAR(o.orderdate),MONTHNAME(o.orderdate))) running_total
FROM employees e 
JOIN orders o
ON e.employeeid = o.employeeid
JOIN order_details od
ON o.orderid = od.orderid
GROUP BY e.employeeid,e.firstname,MONTHNAME(o.orderdate),YEAR(o.orderdate);
-- 5.Identify the top-selling product in each category

SELECT * FROM (SELECT p.categoryid,p.productid,p.productname,
               SUM(od.quantity) quantityselled,
               DENSE_RANK() OVER(PARTITION BY p.categoryid ORDER BY SUM(od.quantity) DESC ) ranking
               FROM products p
               JOIN order_details od 
               ON p.productid = od.productid
               GROUP BY p.productid,p.productname,p.categoryid
               ORDER BY quantityselled DESC)t
               WHERE t.ranking = 1
               ORDER BY t.categoryid;

-- 6. Rank Employee in terms of revenue generation. Show employee id, first name, revenue, and rank

SELECT *,
DENSE_RANK() OVER(ORDER BY t.revenue DESC) ranking_emp
FROM (SELECT e.employeeid,CONCAT(e.firstname,' ',e.lastname) FullName,
ROUND(SUM(unitprice * quantity)) revenue
FROM employees e
JOIN orders o
ON e.employeeid = o.employeeid
JOIN order_details od
ON o.orderid = od.orderid 
GROUP BY e.employeeid,e.firstname,e.lastname) t;

-- 7. Show All products cumulative sum of units sold each month.

SELECT p.productid,p.productname,
MONTHNAME(o.orderdate) month,
SUM(od.quantity) quantitysold,
SUM(SUM(od.quantity)) OVER(PARTITION BY p.productid ORDER BY MONTHNAME(o.orderdate) ASC) Cummulativesum
FROM products p
JOIN order_details od
ON p.productid = od.productid
JOIN orders o 
ON o.orderid = od.orderid
GROUP BY p.productid,p.productname,MONTHNAME(o.orderdate)
ORDER BY p.productid,month;


-- 8. Show Percentage of total revenue by each suppliers

WITH PercRev AS (SELECT s.supplierid,s.contactname,
                 ROUND(SUM(od.unitprice * od.quantity)) revenue
                 FROM suppliers s
                 JOIN products p 
                 ON s.supplierid = p.supplierid
                 JOIN order_details od
                 ON p.productid = od.productid
                 GROUP BY s.supplierid,s.contactname
                 ORDER BY revenue DESC) 
SELECT *,
CONCAT(ROUND((revenue/SUM(revenue) OVER()) * 100,2),'%') RevenuePercentage
FROM PercRev;

-- 9. Show revenue contribution per supplier as a percentage of total revenue 

SELECT s.supplierid,
SUM(od.quantity) totalorders,
CONCAT(ROUND((SUM(od.quantity)/SUM(SUM(od.quantity)) OVER())* 100,1),"%") inpercentage
FROM suppliers s
JOIN products p 
ON s.supplierid = p.supplierid
JOIN order_details od
ON p.productid = od.productid
GROUP BY s.supplierid
ORDER BY totalorders DESC ;

-- 10. Cumulative sum of units sold each month

SELECT MONTHNAME(o.orderdate) month,
SUM(od.quantity) quantitysold,
SUM(SUM(od.quantity)) OVER( ORDER BY MONTH(o.orderdate)) cummalativesum
FROM orders o
JOIN order_details od
ON o.orderid = od.orderid
GROUP BY MONTH(o.orderdate),MONTHNAME(o.orderdate)
ORDER BY MONTH(o.orderdate);

-- 11. Compute the cumulative revenue per customer over time (Years)

SELECT o.customerid,YEAR(o.orderdate) Year,
ROUND(SUM(od.unitprice* od.quantity)) rev ,
SUM(ROUND(SUM(od.unitprice* od.quantity),2)) OVER(PARTITION BY o.customerid ORDER BY YEAR(o.orderdate)) Cum_Rev
FROM orders o
JOIN order_details od
ON o.orderid = od.orderid
GROUP BY o.customerid,YEAR(o.orderdate);

-- 12. Find the first and last order date for each customer

SELECT customerid,
FIRST_VALUE(DATE(orderdate)) OVER(PARTITION BY customerid ORDER BY orderdate) first_order_date,
LAST_VALUE(DATE(orderdate)) OVER(PARTITION BY customerid ORDER BY orderdate
						   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) last_order_date
FROM orders;

--         WE CAN ACHIEVE SAME RESULT BY USING MIN AND MAX FUNCTION 

-- 13. Identify the last 5 orders product name placed by each customer

SELECT * FROM (SELECT o.customerid,p.productid,p.productname,DATE(o.orderdate),
               RANK() OVER(PARTITION BY o.customerid ORDER BY o.orderdate
						   ROWS BETWEEN 5 PRECEDING AND 0 FOLLOWING ) ranking
				FROM orders o
                JOIN order_details od
                ON o.orderid = od.orderid
                JOIN products p
				ON od.productid = p.productid)t
                WHERE t.ranking < 6;
                           
-- 14. Use LEAD() to find the next product a customer ordered after each purchase

WITH orderdetails 
AS ( SELECT o.customerid id ,
	 DATE(o.orderdate) date,
     p.productname productName
     FROM orders o
     JOIN order_details od
     ON o.orderid = od.orderid
     JOIN products p
     ON p.productid = od.productid )
SELECT *,
LEAD(productName) OVER(PARTITION BY id ORDER BY date) NextProductOrdered
FROM orderdetails;

-- 15. Find employees who had a drop in their monthly sales compared to the previous 

WITH MonthlySales
AS (SELECT e.employeeid Id,e.firstname Name,
	MONTH(o.orderdate) month_num,
    MONTHNAME(o.orderdate) Month,
    ROUND(SUM(od.unitprice * od.quantity)) MonthlySales
    FROM employees e 
    JOIN orders o
    ON e.employeeid = o.employeeid
    JOIN order_details od 
    ON o.orderid = od.orderid
    GROUP BY e.employeeid,e.firstname,MONTH(o.orderdate),MONTHNAME(o.orderdate)
    ORDER BY e.employeeid,MONTH(o.orderdate)),
PrevMonthSales AS (
    SELECT id,
    name,
    month,
    monthlysales,
    LAG(MonthlySales) OVER(PARTITION BY id,name ORDER BY month_num ) PrevMonthSale
    FROM MonthlySales)
SELECT *,
CASE
    WHEN monthlysales < PrevMonthSale THEN 'Sales Drop'
    WHEN PrevMonthSale IS NULL THEN 'No Record Found'
    ELSE 'Sales Increase'
    END AS EmpPerformanceTrend
FROM prevMonthSales;

-- 16. Calculate the month-over-month growth in total revenue

WITH monthly_rev_trend 
AS ( SELECT MONTH(o.orderdate) month_num,
     MONTHNAME(o.orderdate) month,
     ROUND(SUM(od.unitprice * od.quantity)) MonthlyRevenue,
     LAG(ROUND(SUM(od.unitprice * od.quantity))) OVER(ORDER BY MONTH(o.orderdate)) PrevMonthRev
     FROM orders o 
     JOIN order_details od
     ON o.orderid = od.orderid
     GROUP BY MONTH(o.orderdate),MONTHNAME(o.orderdate))
SELECT month,
Monthlyrevenue,
PrevMonthRev,
CONCAT(ROUND(((monthlyrevenue - prevmonthrev)/prevmonthrev)*100,2),'%') MOM_Growth
FROM monthly_rev_trend
ORDER BY month_num;

-- 17.	Find the most frequently ordered product per month
-- Show Month, ProductID, ProductName, and total orders.

WITH MostOrderedProduct AS (
    SELECT 
        MONTHNAME(o.orderdate) AS month,
        p.productid AS p_id,
        p.productname AS p_name,
        MONTH(o.orderdate) AS month_num,
        COUNT(*) AS totalorders,
        ROW_NUMBER() OVER(
            PARTITION BY MONTH(o.orderdate)
            ORDER BY COUNT(*) DESC
        ) AS ranking
    FROM products p 
    JOIN order_details od ON p.productid = od.productid
    JOIN orders o ON o.orderid = od.orderid
    GROUP BY MONTH(o.orderdate), MONTHNAME(o.orderdate), p.productid, p.productname
)
SELECT month, p_id, p_name, totalorders
FROM MostOrderedProduct
WHERE ranking = 1
ORDER BY month_num;

-- 18.	Show the average order value (AOV) per employee
-- 	Show EmployeeID, FirstName, and average order value.

WITH AOV_Emp 
AS ( SELECT e.employeeid emp_id,
     e.firstname emp_name,
     ROUND(SUM(od.unitprice * od.quantity)) TotalRev ,
     COUNT(*) total_orders
     FROM employees e
     JOIN orders o ON e.employeeid = o.employeeid
     JOIN order_details od ON o.orderid = od.orderid
     GROUP BY e.employeeid,e.firstname )
SELECT *, 
ROUND(TotalRev/total_orders) AOV_Per_Employee
FROM AOV_Emp
ORDER BY emp_id ;

-- 19.	Calculate each order's contribution to total revenue (as a percentage)
-- Show OrderID, TotalOrderAmount, and its percentage of total revenue.

WITH OrderContributionPerc 
AS ( SELECT o.orderid o_id,
     ROUND(SUM(od.unitprice * od.quantity)) TotalRev
     FROM orders o
     JOIN order_details od
     ON o.orderid = od.orderid
     GROUP BY o.orderid )
SELECT *,
CONCAT(ROUND((totalrev/SUM(totalrev) OVER()) *100,2),'%') RevInPerc
FROM OrderContributionPerc;

-- 20.	Calculate the number of orders per employee per month
--      Show EmployeeID, Month, and the number of orders.

SELECT e.employeeid,
MONTHNAME(DATE(o.orderdate)) month,
COUNT(*) totalorders
FROM employees e
JOIN orders o
ON e.employeeid = o.employeeid
GROUP BY e.employeeid,MONTH(DATE(o.orderdate)),MONTHNAME(DATE(o.orderdate))
ORDER BY e.employeeid,MONTH(DATE(o.orderdate));

-- 21.Calculate the difference in order value between consecutive orders for each customer
--    Show CustomerID, OrderID, OrderValue, and difference with the previous order.

WITH ConsecutiveOrder 
AS ( SELECT o.customerid cust_id,o.orderid o_id,
     DATE(o.orderdate) o_date,
     ROUND(SUM(od.unitprice*od.quantity)) OrderValue
     FROM orders o
     JOIN order_details od 
     ON o.orderid = od.orderid
     GROUP BY o.customerid,o.orderid,DATE(o.orderdate))
,prevorder 
AS (SELECT *,
    LAG(ordervalue) OVER( PARTITION BY cust_id ORDER BY o_date ) Prev_Order_Val
    FROM consecutiveorder )
SELECT 
cust_id,
o_id,
o_date,
ordervalue,
CASE 
    WHEN ordervalue - prev_order_val IS NULL THEN "No Record Found"
    ELSE ordervalue - prev_order_val
    END AS ValueDiff
FROM prevorder;

-- 22.	List the top 3 revenue-generating products each month
--      Show Month, ProductID, ProductName, and rank by revenue.

WITH TOP3PRODUCT 
AS ( SELECT MONTHNAME(o.orderdate) month,
	 MONTH(o.orderdate) month_num,
	 p.productid p_id,p.productname p_name,
     ROUND(SUM(od.unitprice * od.quantity)) Revenue 
     FROM products p
     JOIN order_details od
     ON p.productid = od.productid
     JOIN orders o
     ON od.orderid = o.orderid
     GROUP BY p.productid,p.productname,MONTH(o.orderdate),MONTHNAME(o.orderdate)
     ORDER BY MONTH(o.orderdate),SUM(od.unitprice * od.quantity) DESC )
, RankingProducts 
AS ( SELECT *,
     RANK() OVER(PARTITION BY month ORDER BY month_num ASC,revenue DESC ) ranks
     FROM top3product)
SELECT month,
p_id,p_name,
revenue,
ranks
FROM rankingproducts
WHERE ranks < 4
ORDER BY month_num,ranks;

-- 23.	Find customers whose revenue dropped compared to the previous year           - recheck
--      Show CustomerID, PreviousYearRevenue, CurrentYearRevenue, and difference.

WITH yearly_revenue AS (
    SELECT 
        customerid,
        YEAR(orderdate) AS order_year,
        ROUND(SUM(unitprice * quantity)) AS revenue
    FROM orders o
    JOIN order_details od ON o.orderid = od.orderid
    WHERE YEAR(orderdate) IN (1996, 1997)
    GROUP BY customerid, YEAR(orderdate)
),
revenue_comparison AS (
    SELECT
        customerid,
        MAX(CASE WHEN order_year = 1996 THEN revenue ELSE 0 END) AS previous_year_revenue,
        MAX(CASE WHEN order_year = 1997 THEN revenue ELSE 0 END) AS current_year_revenue
    FROM yearly_revenue
    GROUP BY customerid
)
SELECT
    customerid,
    previous_year_revenue,
    current_year_revenue,
    current_year_revenue - previous_year_revenue AS difference
FROM revenue_comparison
WHERE current_year_revenue < previous_year_revenue;

-- 24. Identify the last 5 orders placed by each customer
--     Show CustomerID, OrderID, OrderDate, and rank orders in descending order.

SELECT * FROM (SELECT customerid,
orderid,
DATE(orderdate) orderdate,
RANK() OVER(PARTITION BY customerid ORDER BY DATE(orderdate) DESC)  ranks
FROM orders ranks
) t
WHERE t.ranks < 6;

-- 25. Use LEAD() to find the next product a customer ordered after each purchase
--     Show CustomerID, OrderID, ProductID, and the next product they ordered.
SELECT customerid,
o.orderid,
DATE(orderdate) date,
productid, 
LEAD(productid) OVER(PARTITION BY customerid,orderid ORDER BY orderdate,orderid, productid ) nextproductordered
FROM orders o
JOIN order_details od
ON o.orderid = od.orderid
ORDER BY date ;

-- 26. Find employees who had a drop in their monthly sales compared to the previous month
--  	Show EmployeeID, Month, total sales, and difference from the previous month.

WITH totalsales_emp 
AS ( SELECT employeeid,
     MONTHNAME(orderdate) Month,
     ROUND(SUM(od.unitprice*od.quantity)) TotalRevenue FROM orders o 
     JOIN order_details od
     ON o.orderid = od.orderid
     GROUP BY employeeid,MONTH(orderdate),MONTHNAME(orderdate)
     ORDER BY employeeid,MONTH(orderdate) )
, prevmonthsale 
AS ( SELECT *, 
     LAG(totalrevenue) OVER() Prevmonthsales
     FROM totalsales_emp
)
SELECT *,
(totalrevenue - prevmonthsales) salesdiff
FROM prevmonthsale;





















