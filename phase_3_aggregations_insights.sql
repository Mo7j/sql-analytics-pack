/*
Project Title: Revenue Concentration, Channel Mix & Performance Tiers (Aggregations)

Your Role:
You are a junior data analyst tasked with summarizing revenue concentration,
customer tiers, sales performance, and marketing channel behavior using aggregation.

Constraints:
You may use ONLY:
SELECT, FROM, JOIN, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT,
Aggregate functions (COUNT, SUM, AVG, MIN, MAX),
DISTINCT,
Date functions (DATE_PART, DATE_TRUNC),
CASE statements,
Derived columns (math)

NO subqueries, NO window functions
*/


-- ===================================================
-- Business Question 1:
-- Which accounts are the biggest revenue drivers overall,
-- and how concentrated is revenue in the top accounts?
-- ===================================================

SELECT
    a.id AS account_id,
    a.name AS account_name,
    SUM(o.total_amt_usd) AS total_revenue_usd,
    COUNT(o.id) AS total_orders,
    AVG(o.total_amt_usd) AS avg_order_value_usd
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_revenue_usd DESC
LIMIT 20;


-- ===================================================
-- Business Question 2:
-- Which accounts have high order volume but low revenue,
-- potentially creating operational cost exposure?
-- ===================================================

SELECT
    a.id AS account_id,
    a.name AS account_name,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amt_usd) AS total_revenue_usd,
    AVG(o.total_amt_usd) AS avg_order_value_usd
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(o.id) >= 20
   AND AVG(o.total_amt_usd) < 500
ORDER BY total_orders DESC, avg_order_value_usd;


-- ===================================================
-- Business Question 3:
-- What are the yearly revenue and order trends?
-- ===================================================

SELECT
    DATE_PART('year', o.occurred_at) AS ord_year,
    COUNT(*) AS total_orders,
    SUM(o.total_amt_usd) AS total_revenue_usd,
    AVG(o.total_amt_usd) AS avg_order_value_usd
FROM orders o
GROUP BY 1
ORDER BY 1;


-- ===================================================
-- Business Question 4:
-- Which month-year periods had the highest revenue,
-- and are there seasonal spikes we should plan for?
-- ===================================================

SELECT
    DATE_TRUNC('month', o.occurred_at) AS ord_month,
    COUNT(*) AS total_orders,
    SUM(o.total_amt_usd) AS total_revenue_usd
FROM orders o
GROUP BY 1
ORDER BY total_revenue_usd DESC
LIMIT 12;


-- ===================================================
-- Business Question 5:
-- Which marketing channels are used most,
-- and does usage differ by region?
-- ===================================================

SELECT
    r.name AS region,
    w.channel,
    COUNT(*) AS num_events
FROM web_events w
JOIN accounts a
    ON w.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;


-- ===================================================
-- Business Question 6:
-- Which accounts are the most engaged on key channels
-- (organic/adwords/facebook), and who dominates each channel?
-- ===================================================

SELECT
    a.id AS account_id,
    a.name AS account_name,
    w.channel,
    COUNT(*) AS channel_events
FROM accounts a
JOIN web_events w
    ON a.id = w.account_id
WHERE w.channel IN ('organic', 'adwords', 'facebook')
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6
ORDER BY channel_events DESC;


-- ===================================================
-- Business Question 7:
-- Segment accounts into customer tiers based on lifetime value
-- (top / middle / low) and rank within each tier by spend.
-- ===================================================

SELECT
    a.id AS account_id,
    a.name AS account_name,
    SUM(o.total_amt_usd) AS total_spent_usd,
    COUNT(o.id) AS total_orders,
    CASE
        WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
        WHEN SUM(o.total_amt_usd) > 100000 THEN 'middle'
        ELSE 'low'
    END AS customer_level
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent_usd DESC;


-- ===================================================
-- Business Question 8:
-- Identify top-performing sales reps using both volume and revenue:
-- - top:   >200 orders OR >750000 total sales
-- - middle:>150 orders OR >500000 total sales
-- - low:   otherwise
-- ===================================================

SELECT
    s.id AS sales_rep_id,
    s.name AS sales_rep,
    r.name AS region,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amt_usd) AS total_sales_usd,
    CASE
        WHEN COUNT(o.id) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
        WHEN COUNT(o.id) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
        ELSE 'low'
    END AS sales_rep_level
FROM sales_reps s
JOIN accounts a
    ON s.id = a.sales_rep_id
JOIN orders o
    ON a.id = o.account_id
JOIN region r
    ON s.region_id = r.id
GROUP BY s.id, s.name, r.name
ORDER BY total_sales_usd DESC;


-- ===================================================
-- Business Question 9:
-- Data integrity check:
-- Are there accounts with unusually low total spend but high engagement,
-- which could indicate leads not converting?
-- ===================================================

SELECT
    a.id AS account_id,
    a.name AS account_name,
    COUNT(w.id) AS total_web_events,
    SUM(o.total_amt_usd) AS total_spent_usd,
    CASE
        WHEN SUM(o.total_amt_usd) IS NULL THEN 0
        ELSE SUM(o.total_amt_usd)
    END AS total_spent_usd_safe
FROM accounts a
LEFT JOIN web_events w
    ON a.id = w.account_id
LEFT JOIN orders o
    ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(w.id) >= 15
   AND (SUM(o.total_amt_usd) IS NULL OR SUM(o.total_amt_usd) < 1000)
ORDER BY total_web_events DESC;
