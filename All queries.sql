---First and last purchase date
SELECT MIN(InvoiceDate) AS FirstOrder, MAX(InvoiceDate) AS LastOrder
FROM uk_purchases;

---Best days of the week (revenue) 
-- 0=Mon 6=Sun
SELECT DAYOFWEEK, ROUND(SUM(TotalPrice), 2) AS revenue
FROM uk_purchases
GROUP BY DAYOFWEEK
ORDER BY revenue DESC;

---AOV 
SELECT COUNT(DISTINCT InvoiceNo) AS orders,
       COUNT(DISTINCT CustomerID) AS customers,
       ROUND(SUM(TotalPrice), 2) AS revenue,
       ROUND(SUM(TotalPrice) / COUNT(DISTINCT InvoiceNo), 2) AS AOV
FROM uk_purchases;

---AOV Year
SELECT Year,
       ROUND(SUM(TotalPrice) / COUNT(DISTINCT InvoiceNo), 2) AS AOVYear
FROM uk_purchases
GROUP BY Year;

---AOV Month
SELECT Month,
       ROUND(SUM(TotalPrice) / COUNT(DISTINCT InvoiceNo), 2) AS AOVYear
FROM uk_purchases
GROUP BY Month;

---Revenue by month
SELECT YearMonth, 
       ROUND(SUM(TotalPrice), 2) AS revenue
FROM uk_purchases
GROUP BY YearMonth
ORDER BY YearMonth;

---Top 10 customers by spending
SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS orders, ROUND(SUM(TotalPrice), 2) AS total_spent
FROM uk_purchases
GROUP BY CustomerID
ORDER BY total_spent DESC
LIMIT 10;

---First and Last Purchase per Customer
SELECT CustomerID,
       MIN(InvoiceDate) AS FirstPurchase,
       MAX(InvoiceDate) AS LastPurchase,
       DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate)) AS DaysBetween
FROM uk_purchases
GROUP BY CustomerID
ORDER BY DaysBetween DESC;

---One or more purchases
SELECT SUM(CASE WHEN orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
       SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) AS repeat_customers
FROM (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS orders
    FROM uk_purchases
    GROUP BY CustomerID
) AS customer_invoices;

---Unique products ranked by times bought
SELECT 
    StockCode, 
    MAX(Description) AS Items, -- Grabs one description per code
    COUNT(*) AS TimesBought,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS PopularityRank
FROM uk_purchases
GROUP BY StockCode
ORDER BY PopularityRank
LIMIT 20;

---Purchase Frequency
WITH PurchaseFreq AS (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency
    FROM uk_purchases
    GROUP BY CustomerID
)
SELECT pf.CustomerID, pf.PurchaseFrequency, fb.Segment AS FrequencySegment
FROM PurchaseFreq pf
JOIN Frequency_Baskets fb ON pf.PurchaseFrequency BETWEEN fb.MinFrequency AND fb.MaxFrequency
ORDER BY pf.PurchaseFrequency DESC;