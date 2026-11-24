-- 1. Establishing the overall form of the dataset

--Checking the size of the dataset
SELECT COUNT(*) AS total_records
FROM 
    ten_thousand_set;

--Finding the earliest and latest order dates
SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM 
    ten_thousand_set;

/*Finding the number of orders in each status
and the total revenue associared with each status*/
SELECT
    status,
    COUNT(order_id) AS order_count,
    SUM(order_total) AS total_revenue
FROM ten_thousand_set
GROUP BY status
ORDER BY order_count DESC;

-- 2. Inspecting and investigating actual sales performance.

--Region Performance By Highest Total Revenue
SELECT
    region,
    COUNT(order_id) AS Numb_of_orders,
    SUM(order_total) AS Total_Revenue,
    ROUND(AVG(order_total),5)AS Average_Sales
FROM
    ten_thousand_set
GROUP BY
    region
ORDER BY
    Total_Revenue DESC;

--Product Performance By Most Units Sold
SELECT
    product,
    COUNT(order_id) AS Numb_of_orders,
    SUM(order_total) AS Total_Revenue,
    SUM(units) AS Units_Sold
FROM
    ten_thousand_set
GROUP BY
    product
ORDER BY
    Units_Sold DESC;

-- Category Performance By Highest Revenue
SELECT
    category,
    SUM(order_total) AS Total_Revenue,
    SUM(units) AS Units_Sold,
    ROUND(AVG(order_total),4) AS Average_Order_Value
FROM
    ten_thousand_set
GROUP BY
    category
ORDER BY
    Total_Revenue DESC;

-- 3. Customer Behaviour Investigation

--Customer Spending Report
SELECT
    customer_id,
    customer_name,
    region,
    COUNT(order_id) AS Numb_orders,
    SUM(order_total) AS Total_Revenue,
    ROUND(AVG(order_total),3) AS Average_Order_Value
FROM
    ten_thousand_set 
GROUP BY
    customer_id,
    customer_name,
    region
ORDER BY
    Total_Revenue DESC;

-- Customer Segmentation By Total Spent

SELECT
    customer_id AS ID,
    customer_name AS Name,
    SUM(order_total) AS Total_Revenue,
    CASE 
        WHEN SUM(order_total) < 500000  THEN 'Starter'
        WHEN SUM(order_total)  BETWEEN 500000 AND 1999999 THEN 'Regular'
        WHEN SUM(order_total)  BETWEEN 2000000 AND 4999999 THEN 'High_Value'
        WHEN SUM(order_total) >= 5000000 THEN 'VIP'
    END AS Customer_Classification
FROM
    ten_thousand_set
GROUP BY    
    ID,
    Name;

-- High Value Customers Via Total Spending and Order Count
SELECT
    customer_id AS ID,
    customer_name AS Name,
    SUM(order_total) AS Total_Revenue,
    COUNT(order_id) AS order_count
FROM
    ten_thousand_set
GROUP BY    
    ID,
    Name
HAVING
    SUM(order_total) >= 2000000 
    AND
    COUNT(order_id) >= 5
ORDER BY
    Total_Revenue DESC;

-- High filter for hidden high performers

WITH ORDERS_2025 AS(
    SELECT *
        FROM
            ten_thousand_set
        WHERE EXTRACT(YEAR FROM order_date) = 2025 
        AND
        status = 'Completed'
)
,CUSTOMER_METRICS AS (
    SELECT  
       COUNT(order_id) Number_of_Orders,
       SUM(order_total) Total_Revenue,
       COUNT (DISTINCT category) AS Number_of_Categories,
       ROUND(AVG(order_total),4) AS Average_Revenue,
       customer_id AS ID,
       customer_name AS Name,
       region
    FROM 
        ORDERS_2025
    WHERE
        order_total IS NOT NULL
    AND NOT
        region IN ('East','West')
    GROUP BY
        ID,
        Name,
        region
    HAVING
        COUNT(order_id) >= 5
    AND
        SUM(order_total) > 2000000
),
 QUALIFIED_CUSTOMERS AS (SELECT
    F.ID,
    F.Name,
    F.region,
    F.Number_of_Orders,
    F.Total_Revenue,
    F.Average_Revenue,
    F.Number_of_Categories,
    MAX(D.order_date) AS Lastest_order_date
FROM
    CUSTOMER_METRICS F
INNER JOIN ORDERS_2025 D ON
 F.ID = D.customer_id
WHERE
    Number_of_Categories >= 2 
GROUP BY
    F.ID,
    F.Name,
    F.region,
    F.Number_of_Orders,
    F.Total_Revenue,
    F.Average_Revenue,
    F.Number_of_Categories
HAVING
    F.Average_Revenue > 250000
)
 SELECT *
FROM
    QUALIFIED_CUSTOMERS
ORDER BY
    Total_Revenue DESC