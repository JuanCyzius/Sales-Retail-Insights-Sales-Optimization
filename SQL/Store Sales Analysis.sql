CREATE DATABASE HDNB;

use HDNB;

-- Import the Excel File --

SELECT *
FROM electronics_sales;

DESCRIBE electronics_sales;

-- Check Missing Values --

SELECT *
FROM electronics_sales
WHERE InvoiceID IS NULL
   OR `Customer ID` IS NULL
   OR UnitPrice IS NULL
   OR Quantity IS NULL
   OR `Total Amount` IS NULL;
   
-- Duplicate Check --

SELECT InvoiceID, COUNT(*)
FROM electronics_sales
GROUP BY InvoiceID
HAVING COUNT(*) > 1;

-- Validate Gross Amount --

SELECT *
FROM electronics_sales
WHERE `Gross Amount` <> UnitPrice * Quantity;

-- Validate Discount Amount --

SELECT *
FROM electronics_sales
WHERE `Discount Amount` <> (`Gross Amount` * Discount / 100);

-- Validate Tax Amount -- 

SELECT *
FROM electronics_sales
WHERE `Tax Amount` <> (`Gross Amount` - `Discount Amount`) * Tax / 100;

-- Validate Total Amount -- 

SELECT *
FROM electronics_sales
WHERE `Total Amount` <>
(`Gross Amount` - `Discount Amount` + `Tax Amount`);


use HDNB;

-- 2. SQL Analysis -- 

-- Overall Sales Performance --

SELECT 
SUM(`Total Amount`) AS total_revenue,
COUNT(InvoiceID) AS total_transactions,
AVG(`Total Amount`) AS avg_transaction_value
FROM electronics_sales;

SELECT 
`Store Branch`,
SUM(`Total Amount`) AS branch_revenue,
ROUND(SUM(`Total Amount`) * 100 / 
(SELECT SUM(`Total Amount`) FROM electronics_sales),2) 
AS revenue_percentage
FROM electronics_sales
GROUP BY `Store Branch`
ORDER BY branch_revenue DESC;

-- Customer Demographics --

-- Total revenue, transaction count, and average value
SELECT 
    SUM(`Total Amount`) AS Total_Revenue,
    COUNT(InvoiceID) AS Total_Transactions,
    AVG(`Total Amount`) AS Avg_Transaction_Value
FROM electronics_sales;

-- Revenue contribution (%) by each store branch

SELECT 
    `Store Branch`,
    SUM(`Total Amount`) AS Branch_Revenue,
    ROUND((SUM(`Total Amount`) / (SELECT SUM(`Total Amount`) FROM electronics_sales) * 100), 2) AS Contribution_Pct
FROM electronics_sales
GROUP BY `Store Branch`
ORDER BY Contribution_Pct DESC;

-- Product and Category Insights --

-- Top 5 product categories by revenue

SELECT `Product Category`, SUM(`Total Amount`) AS Total_Revenue
FROM electronics_sales
GROUP BY `Product Category`
ORDER BY Total_Revenue DESC
LIMIT 5;

-- Top-selling product (by quantity) in each category and branch

WITH RankedProducts AS (
    SELECT 
        `Store Branch`, 
        `Product Category`, 
        `Product Name`, 
        SUM(Quantity) as Total_Qty,
        RANK() OVER(PARTITION BY `Store Branch`, `Product Category` ORDER BY SUM(Quantity) DESC) as rnk
    FROM electronics_sales
    GROUP BY `Store Branch`, `Product Category`, `Product Name`
)
SELECT `Store Branch`, `Product Category`, `Product Name`, Total_Qty
FROM RankedProducts
WHERE rnk = 1;

-- Average discount and profit margin per category
-- Margin = (Total Amount - (0.8 * UnitPrice * Quantity)) / Total Amount
SELECT 
    `Product Category`,
    AVG(Discount) AS Avg_Discount_Pct,
    AVG((`Total Amount` - (0.8 * UnitPrice * Quantity)) / `Total Amount` * 100) AS Avg_Profit_Margin_Pct
FROM electronics_sales
GROUP BY `Product Category`;

-- Payment and Discount Trends --

-- 1. Most popular payment method overall

SELECT `Payment Method`, COUNT(*) AS Transaction_Count
FROM electronics_sales
GROUP BY `Payment Method`
ORDER BY Transaction_Count DESC
LIMIT 1;

-- 2. Most popular payment method per branch

SELECT `Store Branch`, `Payment Method`, Count
FROM (
    SELECT `Store Branch`, `Payment Method`, COUNT(*) AS Count,
    RANK() OVER(PARTITION BY `Store Branch` ORDER BY COUNT(*) DESC) as rnk
    FROM electronics_sales
    GROUP BY `Store Branch`, `Payment Method`
) t WHERE rnk = 1;

-- 3. Correlation check: Discount vs Quantity

-- (SQL doesn't have a native corr function in all dialects, so we look at averages)
SELECT Discount, AVG(Quantity) AS Avg_Qty
FROM electronics_sales
GROUP BY Discount
ORDER BY Discount DESC;

-- 4. Highest average transaction value per payment method

SELECT `Payment Method`, AVG(`Total Amount`) AS Avg_Transaction_Value
FROM electronics_sales
GROUP BY `Payment Method`
ORDER BY Avg_Transaction_Value DESC;

-- Time-Based Analysis -- 

-- 1. Monthly sales trends

SELECT DATE_FORMAT(`Purchase Date`, '%Y-%m') AS Month, SUM(`Total Amount`) AS Monthly_Revenue
FROM electronics_sales
GROUP BY Month
ORDER BY Month;

-- 2. Weekday vs Weekend performance

SELECT 
    CASE WHEN DAYOFWEEK(`Purchase Date`) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END AS Day_Type,
    AVG('Total Amount') AS Avg_Sales
FROM electronics_sales
GROUP BY Day_Type;

-- Customer Experience -- 

-- 1. Avg satisfaction per category

SELECT `Product Category`, AVG(`Satisfaction Rating`) AS Avg_Rating
FROM electronics_sales
GROUP BY `Product Category`
ORDER BY Avg_Rating DESC;

-- 2. Branch with most satisfied customers

SELECT `Store Branch`, AVG(`Satisfaction Rating`) AS Avg_Rating
FROM electronics_sales
GROUP BY `Store Branch`
ORDER BY Avg_Rating DESC
LIMIT 1;

-- High-Value Transactions --

SELECT 
InvoiceID,
`Customer Name`,
`Product Category`,
`Store Branch`,
`Payment Method`,
`Total Amount`
FROM electronics_sales
ORDER BY `Total Amount` DESC
LIMIT 10;