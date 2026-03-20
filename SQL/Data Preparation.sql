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


