#Q1. Identify and fix price discrepancies in the inventory and sales of the products

SELECT s.TransactionID,
s.Price AS TransactionPrice,
p.Price AS InventoryPrice
FROM Sales_transaction s
JOIN product_inventory p 
ON s.ProductID=p.ProductID
WHERE 
s.Price != p.Price;

UPDATE Sales_transaction s 
JOIN product_inventory p
ON s.ProductID=p.ProductID
SET s.price=p.price
WHERE s.price!=p.price;

SELECT *
FROM Sales_transaction ;



#Q2. Identify the performance of product categories.

SELECT 

p.Category,

   SUM(s.QuantityPurchased) AS TotalUnitsSold,

   SUM(s.QuantityPurchased * s.Price) AS TotalSales

FROM Sales_transaction s

JOIN product_inventory p

ON s.ProductID = p.ProductID

GROUP BY Category
ORDER BY TotalSales DESC;



#Q3. Identify the growth trend of the company on a M-o-M basis.

WITH monthly_sales AS(
    SELECT EXTRACT(MONTH FROM TransactionDate) AS month,
    ROUND(SUM(QuantityPurchased*Price),2) AS total_sales
    FROM Sales_transaction
    GROUP BY EXTRACT(MONTH FROM TransactionDate)
)

SELECT 
  month,
  total_sales,
  LAG(total_sales) OVER(ORDER BY month) AS previous_month_sales,
 ROUND((total_sales- LAG(total_sales) OVER(ORDER BY month))/ LAG(total_sales) OVER(ORDER BY month)*100,2) AS mom_growth_percentage
 FROM monthly_sales
 ORDER BY month;


# Q4. Segmenting customers based on total quantity of products they have purchased.

CREATE TABLE customer_segment AS
SELECT CustomerID,
 CASE
     WHEN TotalQtyPurchased <11
     THEN "Low"
     WHEN TotalQtyPurchased BETWEEN 11 AND 30
     THEN "Med"
     ELSE "High"
    END AS CustomerSegment
    FROM(
        SELECT c.CustomerID,
        SUM(s.QuantityPurchased) AS TotalQtyPurchased
        FROM  customer_profiles c 
        JOIN Sales_transaction  s
        WHERE c.CustomerID=s.CustomerID
        GROUP BY CustomerID
    )AS Customer_totals;
    SELECT CustomerSegment, COUNT(*)
    FROM customer_segment 
    GROUP BY CustomerSegment;