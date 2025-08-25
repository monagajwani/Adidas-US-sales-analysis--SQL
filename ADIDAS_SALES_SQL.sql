CREATE SCHEMA adidas_sales;

CREATE TABLE sales
(Retailer varchar(40),
Retailer_ID INT,
Invoice_Date TEXT,
Region VARCHAR (40),
State VARCHAR (40),
City VARCHAR (30),
Product	VARCHAR (40),
Price_per_Unit FLOAT,
Units_Sold INT,
Total_Sales	INT,
Operating_Profit FLOAT,	
Operating_Margin DECIMAL (5,2),
sales_method varchar (40));

 --  IMPORT DATA IN TABLE (SALES) BY LOAD DATA INFILE METHOD
  
  select @@secure_file_priv;
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/adidas_US_sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- DATA CLEANING DONE--

                  -- ADIDAS US SALES ANALYSIS 2020-2021--

-- 1. Which Sales Method Performs Better?
-- Compare total sales among various sales methods--


SELECT 
    sales_method, SUM(Total_Sales) AS TOTAL_SALES_AMOUNT
FROM
    SALES
GROUP BY sales_method
ORDER BY TOTAL_SALES_AMOUNT DESC;



-- 2. Top Performing Regions
-- Find the top 3 regions with highest total sales.


SELECT 
    Region, SUM(Total_Sales) AS total_sales_amount
FROM
    sales
GROUP BY Region
ORDER BY total_sales_amount DESC
LIMIT 3;



-- 3. Men's vs Women's Product Performance
--  Which generates more revenue - Men's products or Women's products?


SELECT 
    SUM(TOTAL_SALES) AS TOTAL_SALES_AMOUNT,
    CASE
        WHEN PRODUCT LIKE 'MEN%' THEN 'MEN_PRODUCT'
        WHEN PRODUCT LIKE 'WOMEN%' THEN 'WOMEN_PRODUCT'
        ELSE 'OTHER'
    END AS PRODUCT_CATEGORY
FROM
    SALES
GROUP BY PRODUCT_CATEGORY;
     

-- -4) Monthly Sales Trends
--  Which month in 2020 had the highest and lowest sales?

UPDATE sales 
SET 
    invoice_date = STR_TO_DATE(invoice_date, '%d-%m-%Y');


ALTER TABLE sales
MODIFY Invoice_Date DATE;

--  MONTHLY TREND OF SALES IN 2020
 
SELECT 
    MONTHNAME(INVOICE_DATE) AS months,
    SUM(total_sales) AS total_sales_amount
FROM
    SALES
GROUP BY months;
    
 --    HIGHEST SALE : 
    
SELECT 
    MONTHNAME(INVOICE_DATE) AS months,
    SUM(total_sales) AS total_sales_amount
FROM
    SALES
GROUP BY months
ORDER BY Total_sales_amount DESC
LIMIT 1;

--  LOWEST SALE :
 
SELECT 
    MONTHNAME(INVOICE_DATE) AS months,
    SUM(total_sales) AS total_sales_amount
FROM
    SALES
GROUP BY months
ORDER BY Total_sales_amount
LIMIT 1;



-- 5. Most Profitable Product Categories
-- Compare average operating profit for Footwear vs Apparel.

SELECT 
    CASE
        WHEN PRODUCT LIKE '%FOOTWEAR' THEN 'FOOTWEAR_CATEGORY'
        WHEN PRODUCT LIKE '%APPAREL' THEN 'APPAREL_CATEGORY'
        ELSE 'OTHER'
    END AS CATEGORIES,
    ROUND(AVG(OPERATING_PROFIT)) AS AVERAGE_PROFIT
FROM
    SALES
GROUP BY CATEGORIES;
     
     
--    6. Best and Worst Performing Cities
-- Find top 10 cities with highest sales and bottom 5 with lowest sales ?


             --  TOP 10 CITIES

SELECT CITY, sum(TOTAL_SALES) AS TOTAL_SALES_AMOUNT,
rank() OVER (ORDER BY  SUM(TOTAL_SALES) DESC) AS RANK_BY_CITY  FROM SALES
GROUP BY CITY
LIMIT 10;


             -- BOTTOM 5 CITIES

SELECT CITY, sum(TOTAL_SALES) AS TOTAL_SALES_AMOUNT,
rank() OVER (ORDER BY  SUM(TOTAL_SALES))AS RANK_BY_CITY  FROM SALES
GROUP BY CITY
LIMIT 5;


-- 7.Top Selling Products by Region
-- Find the #1 best-selling product in each region using window functions?


SELECT
REGION , PRODUCT, SUM(TOTAL_SALES) AS TOTAL_SALES_AMOUNT, 
RANK() OVER(partition by PRODUCT ORDER BY SUM(TOTAL_SALES) DESC) AS RANK_BY_REGION
FROM SALES
GROUP BY REGION, PRODUCT;


-- 8. Sales Comparison with Previous Month
--  For each month, show current month sales vs previous month sales ?


SELECT 
    SUM(Total_sales) AS TOTAL_AMOUNT_SALES,
    MONTHNAME(INVOICE_DATE) AS MONTH_NAME,
    YEAR(INVOICE_DATE) AS YEAR,
    LAG(SUM(Total_sales)) OVER (ORDER BY YEAR(INVOICE_DATE), MONTH(INVOICE_DATE)) AS PREVIOUS_MONTH_SALES
FROM sales 
GROUP BY YEAR(INVOICE_DATE), MONTH(INVOICE_DATE), MONTHNAME(INVOICE_DATE)
ORDER BY YEAR(INVOICE_DATE), MONTH(INVOICE_DATE);


-- Compare relative risk across sales methods using (StdDev / Mean) ; how much we sell, but also how reliably we sell
-- 9. How stable and predictable are sales across different sales channels?

SELECT 
    Sales_Method,
    ROUND(AVG(Total_Sales),2) AS avg_sales,
    ROUND(STDDEV(Total_Sales),2) AS stddev_sales,
    ROUND((STDDEV(Total_Sales)/AVG(Total_Sales))*100,2) AS coeff_of_variation
FROM sales
GROUP BY Sales_Method;


-- 10.Margin Stability Across Time (Risk Measure)
-- How consistent are Adidas’s profit margins month-to-month?

SELECT 
    YEAR(invoice_date) AS sales_year,
    MONTH(invoice_Date) AS sales_month,
    ROUND(AVG(Operating_Margin),2) AS avg_margin,
    ROUND(STDDEV(Operating_Margin),2) AS margin_volatility
FROM sales
GROUP BY sales_year, sales_month
ORDER BY sales_year, sales_month;



--  --
