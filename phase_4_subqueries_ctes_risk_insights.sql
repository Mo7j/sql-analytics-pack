/*
Project Title: Conversion Gaps, Regional Leaders & Revenue Drivers (Subqueries + CTEs)

Your Role:
You are a junior data analyst tasked with identifying revenue drivers,
regional performance leaders, and conversion gaps using subqueries and CTEs.

Constraints:
You may use ONLY:
SELECT, FROM, JOIN, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT,
Aggregate functions (COUNT, SUM, AVG, MIN, MAX),
DISTINCT,
Date functions (DATE_PART, DATE_TRUNC),
CASE statements,
Subqueries,
WITH (CTEs)

NO window functions
*/


-- ===================================================
-- Business Question 1:
-- Which accounts generate the highest lifetime revenue,
-- and what is the average lifetime spend among the top 10?
-- ===================================================

WITH top_accounts AS (
    SELECT
        a.id AS account_id,
        a.name AS account_name,
        SUM(o.total_amt_usd) AS total_spent_usd
    FROM accounts a
    JOIN orders o
        ON a.id = o.account_id
    GROUP BY a.id, a.name
    ORDER BY total_spent_usd DESC
    LIMIT 10
)
SELECT
    AVG(total_spent_usd) AS avg_lifetime_spend_top10_usd
FROM top_accounts;


-- ===================================================
-- Business Question 2:
-- For the single highest-spending account, how engaged are they
-- across marketing channels (web_events)?
-- ===================================================

WITH top_spender AS (
    SELECT
        a.id AS account_id,
        a.name AS account_name,
        SUM(o.total_amt_usd) AS total_spent_usd
    FROM accounts a
    JOIN orders o
        ON a.id = o.account_id
    GROUP BY a.id, a.name
    ORDER BY total_spent_usd DESC
    LIMIT 1
)
SELECT
    t.account_name,
    w.channel,
    COUNT(*) AS num_events
FROM top_spender t
JOIN web_events w
    ON w.account_id = t.account_id
GROUP BY t.account_name, w.channel
ORDER BY num_events DESC;


-- ===================================================
-- Business Question 3:
-- Which sales rep is the top revenue generator in each region?
-- ===================================================

WITH rep_region_sales AS (
    SELECT
        r.name AS region,
        s.id AS sales_rep_id,
        s.name AS sales_rep,
        SUM(o.total_amt_usd) AS total_sales_usd
    FROM region r
    JOIN sales_reps s
        ON r.id = s.region_id
    JOIN accounts a
        ON s.id = a.sales_rep_id
    JOIN orders o
        ON a.id = o.account_id
    GROUP BY r.name, s.id, s.name
),
region_max AS (
    SELECT
        region,
        MAX(total_sales_usd) AS max_sales_usd
    FROM rep_region_sales
    GROUP BY region
)
SELECT
    rrs.region,
    rrs.sales_rep,
    rrs.total_sales_usd
FROM rep_region_sales rrs
JOIN region_max rm
    ON rrs.region = rm.region
   AND rrs.total_sales_usd = rm.max_sales_usd
ORDER BY rrs.total_sales_usd DESC;


-- ===================================================
-- Business Question 4:
-- For the region with the highest total revenue,
-- how many total orders were placed?
-- ===================================================

WITH region_sales AS (
    SELECT
        r.name AS region,
        SUM(o.total_amt_usd) AS total_sales_usd
    FROM region r
    JOIN sales_reps s
        ON r.id = s.region_id
    JOIN accounts a
        ON s.id = a.sales_rep_id
    JOIN orders o
        ON a.id = o.account_id
    GROUP BY r.name
),
top_region AS (
    SELECT region
    FROM region_sales
    ORDER BY total_sales_usd DESC
    LIMIT 1
)
SELECT
    r.name AS region,
    COUNT(o.id) AS total_orders
FROM region r
JOIN sales_reps s
    ON r.id = s.region_id
JOIN accounts a
    ON s.id = a.sales_rep_id
JOIN orders o
    ON a.id = o.account_id
WHERE r.name = (SELECT region FROM top_region)
GROUP BY r.name;


-- ===================================================
-- Business Question 5:
-- Do we have highly engaged accounts (many web events)
-- that are not converting into high-value customers?
--
-- Definition:
-- - High engagement: >= 20 web events
-- - Low conversion: lifetime spend < 1000 OR no orders
-- ===================================================

WITH account_engagement AS (
    SELECT
        a.id AS account_id,
        a.name AS account_name,
        COUNT(w.id) AS total_web_events
    FROM accounts a
    JOIN web_events w
        ON a.id = w.account_id
    GROUP BY a.id, a.name
    HAVING COUNT(w.id) >= 20
),
account_spend AS (
    SELECT
        a.id AS account_id,
        SUM(o.total_amt_usd) AS total_spent_usd
    FROM accounts a
    LEFT JOIN orders o
        ON a.id = o.account_id
    GROUP BY a.id
)
SELECT
    e.account_name,
    e.total_web_events,
    COALESCE(s.total_spent_usd, 0) AS total_spent_usd
FROM account_engagement e
JOIN account_spend s
    ON e.account_id = s.account_id
WHERE COALESCE(s.total_spent_usd, 0) < 1000
ORDER BY e.total_web_events DESC;


-- ===================================================
-- Business Question 6:
-- On which day-channel pairs did we see the highest event spikes,
-- and which channels show the highest average events per day?
-- ===================================================

WITH daily_events AS (
    SELECT
        DATE_TRUNC('day', occurred_at) AS day,
        channel,
        COUNT(*) AS events
    FROM web_events
    GROUP BY 1, 2
)
SELECT
    channel,
    AVG(events) AS avg_events_per_day
FROM daily_events
GROUP BY channel
ORDER BY avg_events_per_day DESC;


-- ===================================================
-- Business Question 7:
-- First-month baseline:
-- For the first month in the orders table, what were the average quantities
-- of each paper type, and total revenue?
-- ===================================================

WITH first_month AS (
    SELECT DATE_TRUNC('month', MIN(occurred_at)) AS first_month
    FROM orders
)
SELECT
    AVG(o.standard_qty) AS avg_standard_qty,
    AVG(o.gloss_qty) AS avg_gloss_qty,
    AVG(o.poster_qty) AS avg_poster_qty,
    SUM(o.total_amt_usd) AS total_revenue_usd
FROM orders o
WHERE DATE_TRUNC('month', o.occurred_at) = (SELECT first_month FROM first_month);
