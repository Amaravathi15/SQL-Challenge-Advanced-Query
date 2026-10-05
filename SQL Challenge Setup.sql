
CREATE DATABASE SQL_Challenge;

Use SQL_Challenge

DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
  emp_id INTEGER PRIMARY KEY, name VARCHAR(50), dept VARCHAR(50),
  salary INTEGER, hire_date VARCHAR(50), mgr_id INTEGER
);
INSERT INTO Employees VALUES
(1,'Arjun','Sales',120000,'2020-01-15',NULL),
(2,'Priya','Sales',95000,'2020-06-01',1),
(3,'Rahul','Sales',95000,'2021-03-10',1),
(4,'Kiran','Sales',72000,'2022-08-20',2),
(5,'Divya','Sales',68000,'2023-01-05',2),
(6,'Sneha','Tech',150000,'2019-05-11',NULL),
(7,'Vikram','Tech',135000,'2020-02-17',6),
(8,'Meera','Tech',135000,'2021-07-30',6),
(9,'Ravi','Tech',110000,'2022-11-14',7),
(10,'Tara','Tech',88000,'2023-04-22',7),
(11,'Aman','HR',90000,'2021-09-09',NULL),
(12,'Zoya','HR',75000,'2022-02-28',11);

DROP TABLE IF EXISTS Sales;
CREATE TABLE Sales (
  sale_id INTEGER PRIMARY KEY, emp_id INTEGER,
  sale_date VARCHAR(50), region VARCHAR(50), amount REAL
);
INSERT INTO Sales VALUES
(1,2,'2024-01-05','North',12000),(2,2,'2024-01-20','North',8000),
(3,3,'2024-01-11','South',15000),(4,3,'2024-02-14','South',9000),
(5,4,'2024-02-03','North',5000),(6,4,'2024-03-18','East',7000),
(7,5,'2024-03-02','South',11000),(8,2,'2024-03-25','North',14000),
(9,3,'2024-04-08','South',6000),(10,5,'2024-04-19','East',18000),
(11,2,'2024-05-06','North',9500),(12,4,'2024-05-21','North',4500),
(13,3,'2024-06-02','South',22000),(14,5,'2024-06-27','East',13000),
(15,2,'2024-07-14','North',16000);

DROP TABLE IF EXISTS Products;
CREATE TABLE Products (product_id INTEGER, category VARCHAR(50), price REAL, launch_date VARCHAR(50));
INSERT INTO Products VALUES
(1,'Laptop',85000,'2023-01-10'),(2,'Laptop',65000,'2023-06-15'),
(3,'Phone',45000,'2023-02-20'),(4,'Phone',32000,'2024-01-08'),
(5,'Phone',28000,'2024-03-12'),(6,'Tablet',38000,'2023-09-01'),
(7,'Tablet',22000,'2024-02-14'),(8,'Monitor',18000,'2023-11-05');



--1Q — Salary Ranking With Ties

SELECT
    dept,
    name,
    salary,
    DENSE_RANK() OVER (
        PARTITION BY dept
        ORDER BY salary DESC
    ) AS salary_rank,
    MAX(salary) OVER (
        PARTITION BY dept
    ) - salary AS below_top_earner
FROM Employees
ORDER BY dept, salary_rank, name;

--DENSE_RANK() because employees with the same salary share the same rank without skipping numbers. 
--RANK() → 1, 2, 2, 4 (skips 3), DENSE_RANK() → 1, 2, 2, 3


--Q2 — Month-Over-Month Growth

WITH MonthlySales AS (
    SELECT
        FORMAT(CAST(sale_date AS DATE), 'yyyy-MM') AS sale_month,
        SUM(amount) AS total_sales
    FROM Sales
    GROUP BY FORMAT(CAST(sale_date AS DATE), 'yyyy-MM')
)
SELECT
    sale_month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY sale_month) AS previous_month_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY sale_month))
        * 100.0
        / NULLIF(LAG(total_sales) OVER (ORDER BY sale_month), 0),
        2
    ) AS pct_change
FROM MonthlySales
ORDER BY sale_month;


--Q3 — Top Performer Per Region

WITH RegionalSales AS (
    SELECT
        s.region,
        e.emp_id,
        e.name,
        SUM(s.amount) AS total_sales
    FROM Sales s
    JOIN Employees e
        ON s.emp_id = e.emp_id
    GROUP BY s.region, e.emp_id, e.name
),
RankedSales AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY region
               ORDER BY total_sales DESC
           ) AS sales_rank
    FROM RegionalSales
)
SELECT
    region,
    emp_id,
    name,
    total_sales
FROM RankedSales
WHERE sales_rank = 1
ORDER BY region, name;
