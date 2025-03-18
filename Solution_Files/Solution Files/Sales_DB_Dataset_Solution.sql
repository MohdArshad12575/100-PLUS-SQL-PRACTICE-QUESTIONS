
--  1. Retrieve the sales records along with customer details.

SELECT * FROM sales1 s
JOIN customers c 
ON s.customerid = c.customerid;

--  2. Get the list of products that have been sold.

SELECT p.productid,p.name FROM products p
JOIN sales1 s 
ON p.productid = s.productid;

## LEFT JOIN Questions
-- 3. List all customers and their corresponding sales details.

SELECT * FROM customers c
LEFT JOIN sales1 s 
ON c.customerid = s.customerid;

-- 4. Retrieve all employees along with their sales records.

SELECT e.employeeid,e.firstname,s.salesid,s.productid,s.quantity FROM employees e 
LEFT JOIN sales1 s 
ON e.employeeid = s.salespersonid;

## RIGHT JOIN Questions
 -- 5. Retrieve all sales transactions and their corresponding employees.
 
 SELECT * FROM employees e 
 JOIN sales1 s
 ON  s.salespersonid = e.employeeid;
 
 -- 6. Find the top 5 customers who have spent the most money.
 
SELECT c.customerid,c.firstname,c.lastname,
ROUND(SUM(p.price * s.quantity)) totalspend
FROM customers c
JOIN sales1 s
ON c.customerid = s.customerid
JOIN products p
ON s.productid = p.productid
GROUP BY c.customerid,c.firstname,c.lastname
ORDER BY ROUND(SUM(p.price)) DESC
LIMIT 5 ;

-- 7. Get a list of employees who made at least 3 sales, 
-- sorted by the number of sales in descending order
 
 SELECT e.employeeid,e.firstname,e.lastname,
 COUNT(salesid) noofsales
 FROM employees e
 JOIN sales1 s
 ON e.employeeid = s.salespersonid
 GROUP BY e.employeeid,e.firstname,e.lastname
 HAVING noofsales > 3 
 ORDER BY noofsales DESC;
 
 -- 8. List all products and show how many times 
 -- each was sold (including those never sold).
 
 SELECT p.productid,p.name,
 COUNT(*) totalno
 FROM products P
 LEFT JOIN sales1 s
 ON p.productid = s.productid
 GROUP BY p.productid,p.name
 ORDER BY totalno DESC;
 
 -- 9. Find customers who have purchased more than 10 units in total.
 
 SELECT c.customerid,c.firstname,c.lastname,
 COUNT(s.quantity) units
 FROM customers c 
 JOIN sales1 s
 ON c.customerid = s.customerid
 GROUP BY c.customerid,c.firstname,c.lastname
 HAVING units > 10;
 
 -- 10. Retrieve the most expensive product sold and the employee who sold it.
 
 SELECT e.EmployeeID, e.FirstName, e.LastName, p.Name AS ProductName, p.Price
        FROM sales1 s
        INNER JOIN employees e ON s.SalesPersonID = e.EmployeeID
        INNER JOIN products p ON s.ProductID = p.ProductID
        ORDER BY p.Price DESC
        LIMIT 1;

-- 11. Get the average quantity of products sold per customer.

SELECT c.customerid,c.firstname,c.lastname,
AVG(s.quantity) FROM customers c 
JOIN sales1 s 
ON c.customerid = s.customerid
JOIN products p
ON s.productid = p.productid
GROUP BY c.customerid,c.firstname,c.lastname;

-- 12. Find products that have never been sold.

SELECT p.productid,p.name,
s.salesid,s.productid FROM products p
LEFT JOIN sales1 s 
ON p.productid = s.productid 
WHERE s.productid IS NULL;
-- 13. Get the top 3 employees who sold the highest number of unique products.

SELECT e.employeeid,e.firstname,e.lastname,
COUNT(DISTINCT s.productid) countuniqueproduct 
FROM employees e 
JOIN sales1 s
ON e.employeeid = s.salespersonid
GROUP BY e.employeeid,e.firstname,e.lastname
ORDER BY countuniqueproduct  DESC
LIMIT 3;


-- 14 List all employees and their total sales amount, including those who made no sales.

SELECT e.employeeid,e.firstname,e.lastname,
CEIL(SUM(price)) totalsales 
FROM employees e 
LEFT JOIN sales1 s 
ON e.employeeid = s.salespersonid
LEFT JOIN products p 
ON s.productid = p.productid
GROUP BY e.employeeid,e.firstname,e.lastname;

-- Get the top 3 most frequently sold products.
 
 SELECT p.productid,p.name,
 COUNT(*) nooftimessold
 FROM products p 
 JOIN sales1 s 
 ON p.productid = s.productid
 GROUP BY p.productid,p.name
 ORDER BY nooftimessold DESC 
 LIMIT 3;
 
 -- 15. Retrieve the total sales amount for each customer, including their full name.
 
SELECT c.customerid,c.firstname,c.lastname,
CONCAT(c.firstname,' ',c.lastname) fullname,
CEIL(SUM(p.price)) totalsalesamount
FROM customers c 
JOIN sales1 s
ON  c.customerid = s.customerid
JOIN products p
ON s.productid = p.productid
GROUP BY c.customerid,c.firstname,c.lastname ;

-- 16 Find the top 3 best-selling products (by revenue).

SELECT p.productid,p.name,
CEIL(SUM(p.price * s.quantity)) Revenue 
FROM products p
JOIN sales1 s 
ON p.productid = s.productid 
GROUP BY p.productid,p.name
ORDER BY revenue DESC
LIMIT 3;

-- 17.Get the name of the salesperson who made the highest total sales.

SELECT e.employeeid,e.firstname,e.lastname,
CONCAT(e.firstname,' ',e.lastname) fullname,
CEIL(SUM(p.price * s.quantity)) totalsales FROM employees e
JOIN sales1 s
ON e.employeeid = s.salespersonid
JOIN products p 
ON s.productid = p.productid
GROUP BY e.employeeid,e.firstname,e.lastname
ORDER BY totalsales DESC 
LIMIT 1;

-- 18. Find customers who have never made a purchase.

SELECT c.customerid,
CONCAT(c.firstname,c.lastname) fullname
FROM customers c
LEFT JOIN sales1 s 
ON c.customerid = s.customerid
WHERE s.salesid IS NULL;

-- 19. Retrieve the highest single transaction (most expensive order) along 
-- with product and customer details.

SELECT s.salesid,
CONCAT(c.firstname,' ',c.lastname) FullName,
p.name,
CEIL(p.price * s.quantity) totaltransaction
FROM customers c
JOIN sales1 s
ON c.customerid = s.customerid
JOIN products p 
ON s.productid = p.productid
WHERE CEIL(p.price * s.quantity)  = ( SELECT CEIL(MAX(p2.price * s2.quantity)) 
                                           FROM products p2
                                           JOIN sales1 s2 
                                           ON p2.productid = s2.productid);
                                           
-- 20. List all customers who have purchased more than 5 different products.
									
	SELECT s.customerid,
    COUNT( DISTINCT s.productid) productcount
    FROM customers c
    JOIN sales1 s
    ON c.customerid = s.customerid
    GROUP BY s.customerid
    HAVING productcount > 5;
    
-- 21. For each salesperson, show total revenue and rank them based on performance.

SELECT *,
DENSE_RANK() OVER(ORDER BY t.revenue DESC) emp_rank
FROM (SELECT e.employeeid,e.firstname,e.lastname,
      ROUND(SUM(p.price)) revenue
      FROM  employees e 
      JOIN sales1 s
      ON e.employeeid = s.salespersonid
      JOIN products p
      ON s.productid = p.productid
      GROUP BY e.employeeid,e.firstname,e.lastname
      ORDER BY revenue DESC) t;
      
-- 22. Find the most expensive product sold and who bought it.

SELECT p.productid,p.name,
p.price , c.customerid,c.firstname customername_who_bought
FROM products p
JOIN sales1 s
ON p.productid = s.productid
JOIN customers c
ON s.customerid = c.customerid
ORDER BY p.price DESC
LIMIT 1;

-- 23. Calculate the average order value per customer and categorize them 
-- as 'High', 'Medium', or 'Low' spenders.

SELECT c.customerid,
CONCAT(c.firstname,' ',c.lastname) fullname,
ROUND(AVG(p.price * s.quantity)) avgval,
   CASE 
           WHEN AVG(p.Price * s.Quantity) > 1000 THEN 'High'
           WHEN AVG(p.Price * s.Quantity) BETWEEN 500 AND 1000 THEN 'Medium'
           ELSE 'Low'
       END AS SpendingCategory
FROM customers c
JOIN sales1 s
ON c.customerid = s.customerid
JOIN products p
ON s.productid = p.productid
GROUP BY c.customerid,c.firstname,c.lastname;





                                           

