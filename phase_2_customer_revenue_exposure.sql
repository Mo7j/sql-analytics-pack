/*
Project Title: Customer Revenue Exposure & Sales Coverage Analysis (JOIN-Based)

Your Role:
You are a junior data analyst tasked with evaluating customer revenue risk,
sales coverage, and potential data integrity issues using relational data.

Constraints:
You may use ONLY:
SELECT, FROM, JOIN, WHERE, ORDER BY, LIMIT,
Logical operators (AND, OR, NOT, IN, BETWEEN, LIKE),
Derived columns (math)

NO GROUP BY, subqueries, window functions
*/

-- ===================================================
-- Business Question 1:
-- Which accounts generate the highest-value individual orders,
-- and which sales reps and regions are exposed to this risk?
-- ===================================================

SELECT
    o.id AS order_id,
    a.name AS account_name,
    s.name AS sales_rep,
    r.name AS region,
    o.total_amt_usd
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id
WHERE o.total_amt_usd > 0
ORDER BY o.total_amt_usd DESC
LIMIT 20;


-- ===================================================
-- Business Question 2:
-- Are there low-value orders tied to accounts with active sales reps,
-- potentially wasting sales and fulfillment effort?
-- ===================================================

SELECT
    o.id AS order_id,
    a.name AS account_name,
    s.name AS sales_rep,
    o.total_amt_usd
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
WHERE o.total_amt_usd < 100
ORDER BY o.total_amt_usd;


-- ===================================================
-- Business Question 3:
-- Which regions and sales reps are associated with single-product orders,
-- and how extreme are those orders in value?
-- ===================================================

SELECT
    a.name AS account_name,
    s.name AS sales_rep,
    r.name AS region,
    o.standard_qty,
    o.gloss_qty,
    o.poster_qty,
    o.total_amt_usd
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id
WHERE
    (o.standard_qty > 0 AND o.gloss_qty = 0 AND o.poster_qty = 0)
 OR (o.gloss_qty > 0 AND o.standard_qty = 0 AND o.poster_qty = 0)
 OR (o.poster_qty > 0 AND o.standard_qty = 0 AND o.gloss_qty = 0)
ORDER BY o.total_amt_usd DESC;


-- ===================================================
-- Business Question 4:
-- Are there suspicious unit prices associated with specific accounts,
-- reps, or regions that may indicate data quality issues?
-- ===================================================

SELECT
    a.name AS account_name,
    s.name AS sales_rep,
    r.name AS region,
    o.id AS order_id,
    o.standard_qty,
    o.standard_amt_usd / (o.standard_qty + 0.01) AS standard_unit_price
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id
WHERE o.standard_qty > 0
  AND (
        o.standard_amt_usd / (o.standard_qty + 0.01) > 10
     OR o.standard_amt_usd / (o.standard_qty + 0.01) < 0.1
  )
ORDER BY standard_unit_price DESC;


-- ===================================================
-- Business Question 5:
-- Which accounts show recent marketing engagement
-- but may not yet have strong order value?
-- ===================================================

SELECT
    a.name AS account_name,
    w.channel,
    w.occurred_at,
    o.total_amt_usd
FROM web_events w
JOIN accounts a
    ON w.account_id = a.id
LEFT JOIN orders o
    ON a.id = o.account_id
       AND o.total_amt_usd > 500
WHERE w.channel IN ('organic', 'adwords')
  AND o.id IS NULL
ORDER BY w.occurred_at DESC
LIMIT 50;


-- ===================================================
-- Business Question 6:
-- Are there accounts with sales reps assigned
-- but no recorded web engagement?
-- ===================================================

SELECT
    a.name AS account_name,
    s.name AS sales_rep,
    w.channel
FROM accounts a
JOIN sales_reps s
    ON a.sales_rep_id = s.id
LEFT JOIN web_events w
    ON a.id = w.account_id
WHERE w.channel IS NULL
ORDER BY a.name;


-- ===================================================
-- Business Question 7:
-- Do any orders belong to accounts or regions
-- that could cause downstream reporting failures?
-- ===================================================

SELECT
    o.id AS order_id,
    a.name AS account_name,
    r.name AS region,
    o.total_amt_usd,
    o.standard_qty,
    o.gloss_qty,
    o.poster_qty
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id
WHERE
    o.total_amt_usd = 0
    OR (o.standard_qty = 0 AND o.gloss_qty = 0 AND o.poster_qty = 0)
ORDER BY o.id;
