/*
Project Title: Order Quality & Revenue Risk Analysis (SQL-Only)

Your Role: You are a junior data analyst asked to audit order data and
answer management questions about revenue quality, risk, and anomalies.

Constraints

You may use ONLY:
SELECT, FROM, WHERE, ORDER BY, LIMIT,
Logical operators (AND, OR, NOT, IN, BETWEEN, LIKE),
Derived columns (math)

NO JOIN, GROUP BY, subqueries, window functions
*/


-- ===================================================
-- Business Question 1: 
-- Are we overly dependent on a small number of very large orders,
-- and are those orders dominated by a single product?
--
-- Why this matters:
-- Revenue concentration combined with product concentration
-- increases financial and operational risk.
-- ===================================================

SELECT
    id,
    account_id,
    total_amt_usd,
    (standard_amt_usd / total_amt_usd) * 100 AS standard_pct
FROM orders
WHERE total_amt_usd > 0
ORDER BY total_amt_usd DESC
LIMIT 20;



-- ===================================================
-- Business Question 2:
-- Do we have a significant number of very low-value orders
-- that may not justify their operational and fulfillment costs?
--
-- Why this matters:
-- Low-revenue orders can consume logistics, inventory, and support
-- resources disproportionately, reducing overall profitability
-- even if total sales appear healthy.
-- ===================================================

SELECT
    id,
    account_id,
    total_amt_usd,
    standard_qty,
    gloss_qty,
    poster_qty
FROM orders
WHERE total_amt_usd < 100
  AND (standard_qty > 0 OR gloss_qty > 0 OR poster_qty > 0)
ORDER BY total_amt_usd;



-- ===================================================
-- Business Question 3:
-- Are there orders that contain only a single product type,
-- and how extreme are these single-product orders in value?
--
-- Why this matters:
-- Orders dominated by a single product can indicate customer
-- dependency on specific SKUs, increase supply-chain risk,
-- and reduce flexibility in pricing and inventory planning.
-- ===================================================

-- Standard-only orders --
SELECT
    id,
    account_id,
    standard_qty,
    gloss_qty,
    poster_qty,
    total_amt_usd
FROM orders
WHERE standard_qty > 0
  AND gloss_qty = 0
  AND poster_qty = 0
ORDER BY total_amt_usd DESC;
-- Gloss-only orders --
SELECT
    id,
    account_id,
    standard_qty,
    gloss_qty,
    poster_qty,
    total_amt_usd
FROM orders
WHERE gloss_qty > 0
  AND standard_qty = 0
  AND poster_qty = 0
ORDER BY total_amt_usd DESC;
-- Poster-only orders --
SELECT
    id,
    account_id,
    standard_qty,
    gloss_qty,
    poster_qty,
    total_amt_usd
FROM orders
WHERE poster_qty > 0
  AND standard_qty = 0
  AND gloss_qty = 0
ORDER BY total_amt_usd DESC;



-- ===================================================
-- Business Question 4:
-- Are there pricing anomalies in unit prices that may indicate
-- data quality issues or incorrect order entries?
--
-- Why this matters:
-- Extreme unit prices can signal data errors, mispricing,
-- or system bugs that can distort revenue analysis
-- and lead to incorrect business decisions.
-- ===================================================

SELECT
    id,
    account_id,
    standard_qty,
    standard_amt_usd / standard_qty AS standard_unit_price,
    gloss_qty,
    gloss_amt_usd / gloss_qty AS gloss_unit_price,
    poster_qty,
    poster_amt_usd / poster_qty AS poster_unit_price
FROM orders
WHERE
    (
        (standard_qty > 0 AND (standard_amt_usd / standard_qty > 10 OR standard_amt_usd / standard_qty < 0.1))
        OR
        (gloss_qty > 0 AND (gloss_amt_usd / gloss_qty > 10 OR gloss_amt_usd / gloss_qty < 0.1))
        OR
        (poster_qty > 0 AND (poster_amt_usd / poster_qty > 10 OR poster_amt_usd / poster_qty < 0.1))
    )
ORDER BY id;



-- ===================================================
-- Business Question 5:
-- Do high-value orders cluster around specific time periods
-- that may indicate seasonality or campaign-driven behavior?
--
-- Why this matters:
-- Identifying temporal concentration of high-value orders
-- supports forecasting, staffing, and promotional planning.
-- ===================================================

SELECT
    id,
    account_id,
    occurred_at,
    total_amt_usd
FROM orders
WHERE total_amt_usd > 0
ORDER BY occurred_at, total_amt_usd DESC
LIMIT 50;



-- ===================================================
-- Business Question 6:
-- What does recent engagement through organic and adwords
-- channels look like, as an early indicator of lead quality?
--
-- Why this matters:
-- Understanding inbound channel activity helps assess whether
-- high-effort marketing channels may later translate into
-- valuable customer orders.
-- ===================================================

SELECT
    id,
    account_id,
    channel,
    occurred_at
FROM web_events
WHERE channel IN ('organic', 'adwords')
  AND occurred_at BETWEEN '2016-01-01' AND '2016-12-31'
ORDER BY occurred_at DESC;



-- ===================================================
-- Business Question 7:
-- Are there orders that could break downstream analytics
-- due to zero values or invalid data combinations?
--
-- Why this matters:
-- Identifying problematic rows early prevents calculation errors,
-- misleading metrics, and failures in automated reporting systems.
-- ===================================================

SELECT
    id,
    account_id,
    total_amt_usd,
    standard_qty,
    gloss_qty,
    poster_qty
FROM orders
WHERE
    total_amt_usd = 0
    OR (standard_qty = 0 AND gloss_qty = 0 AND poster_qty = 0)
ORDER BY id;
