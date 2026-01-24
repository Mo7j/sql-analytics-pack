/*
Project Title: Revenue Distribution, Trends & Ranking Analysis (Window Functions)

Your Role:
You are a junior data analyst asked to analyze revenue trends,
customer ranking, and performance changes over time using window functions.

Constraints:
You may use ONLY:
SELECT, FROM, JOIN, WHERE, ORDER BY, LIMIT,
Window functions (OVER, PARTITION BY),
ROW_NUMBER, RANK, DENSE_RANK,
Aggregates OVER(),
LAG / LEAD,
Percentiles

NO subqueries for ranking logic
*/


-- ===================================================
-- Business Question 1:
-- Which orders are the top 20 highest-value orders overall,
-- and how do they rank globally?
-- ===================================================

SELECT
    id AS order_id,
    account_id,
    total_amt_usd,
    RANK() OVER (ORDER BY total_amt_usd DESC) AS revenue_rank
FROM orders
ORDER BY revenue_rank
LIMIT 20;


-- ===================================================
-- Business Question 2:
-- Rank orders within each account to identify
-- each customer's largest purchases.
-- ===================================================

SELECT
    id AS order_id,
    account_id,
    total_amt_usd,
    RANK() OVER (PARTITION BY account_id ORDER BY total_amt_usd DESC) AS account_rank
FROM orders
ORDER BY account_id, account_rank;


-- ===================================================
-- Business Question 3:
-- Show lifetime revenue per account on every order
-- (no GROUP BY collapse).
-- ===================================================

SELECT
    id AS order_id,
    account_id,
    total_amt_usd,
    SUM(total_amt_usd) OVER (PARTITION BY account_id) AS lifetime_revenue
FROM orders;


-- ===================================================
-- Business Question 4:
-- How does revenue evolve over time?
-- Compute cumulative revenue.
-- ===================================================

SELECT
    occurred_at,
    total_amt_usd,
    SUM(total_amt_usd) OVER (ORDER BY occurred_at) AS cumulative_revenue
FROM orders
ORDER BY occurred_at;


-- ===================================================
-- Business Question 5:
-- Identify sharp changes in order value by comparing
-- each order to the previous one.
-- ===================================================

SELECT
    id AS order_id,
    occurred_at,
    total_amt_usd,
    LAG(total_amt_usd) OVER (ORDER BY occurred_at) AS previous_order,
    total_amt_usd - LAG(total_amt_usd) OVER (ORDER BY occurred_at) AS revenue_change
FROM orders
ORDER BY occurred_at;


-- ===================================================
-- Business Question 6:
-- Segment orders by revenue percentiles
-- to understand distribution.
-- ===================================================

SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_amt_usd) AS p25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_amt_usd) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_amt_usd) AS p75
FROM orders;
