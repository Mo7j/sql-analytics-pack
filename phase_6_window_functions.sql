-- WINDOW FUNCTIONS --

-- ROW_NUMBER & RANK --

-- 1. Return top 20 orders by total_amt_usd and show:
--    row_number, rank, dense_rank
SELECT
    id,
    account_id,
    total_amt_usd,
    ROW_NUMBER() OVER (ORDER BY total_amt_usd DESC) AS row_num,
    RANK() OVER (ORDER BY total_amt_usd DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY total_amt_usd DESC) AS dense_rank_num
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 20;

-- 2. Rank orders within each account by total_amt_usd (largest orders first)
SELECT
    id,
    account_id,
    total_amt_usd,
    RANK() OVER (PARTITION BY account_id ORDER BY total_amt_usd DESC) AS acct_rank
FROM orders
ORDER BY account_id, acct_rank;

-- 3. For each account, return only the top 1 order (largest)
-- NOTE: Use ROW_NUMBER so ties don’t return multiple rows
SELECT *
FROM (
    SELECT
        id,
        account_id,
        total_amt_usd,
        ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY total_amt_usd DESC) AS rn
    FROM orders
) t1
WHERE rn = 1
ORDER BY total_amt_usd DESC;


-- AGGREGATES IN WINDOW FUNCTIONS --

-- 1. Show each order with the account lifetime spend (without collapsing rows)
SELECT
    id,
    account_id,
    total_amt_usd,
    SUM(total_amt_usd) OVER (PARTITION BY account_id) AS lifetime_spend
FROM orders;

-- 2. Show each order with a running revenue total over time
SELECT
    occurred_at,
    total_amt_usd,
    SUM(total_amt_usd) OVER (ORDER BY occurred_at) AS running_revenue
FROM orders
ORDER BY occurred_at;

-- 3. Show each order with the average order value for its account
SELECT
    id,
    account_id,
    total_amt_usd,
    AVG(total_amt_usd) OVER (PARTITION BY account_id) AS acct_avg_order
FROM orders;


-- ALIASES FOR MULTIPLE WINDOW FUNCTIONS --

-- 1. Use a WINDOW alias to avoid repeating OVER(...) logic
SELECT
    id,
    account_id,
    total_amt_usd,
    RANK() OVER w AS acct_rank,
    SUM(total_amt_usd) OVER w AS acct_lifetime_spend,
    AVG(total_amt_usd) OVER w AS acct_avg_order
FROM orders
WINDOW w AS (PARTITION BY account_id ORDER BY total_amt_usd DESC);


-- COMPARING A ROW TO PREVIOUS ROW (LAG/LEAD) --

-- 1. Compare each order to the previous order by time (overall)
SELECT
    id,
    occurred_at,
    total_amt_usd,
    LAG(total_amt_usd) OVER (ORDER BY occurred_at) AS prev_order_amt,
    total_amt_usd - LAG(total_amt_usd) OVER (ORDER BY occurred_at) AS change_from_prev
FROM orders
ORDER BY occurred_at;

-- 2. Compare each order to the previous order within the same account
SELECT
    id,
    account_id,
    occurred_at,
    total_amt_usd,
    LAG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY occurred_at) AS prev_acct_order_amt
FROM orders
ORDER BY account_id, occurred_at;


-- PERCENTILES --

-- 1. Find p25, median, p75 of total_amt_usd
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_amt_usd) AS p25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_amt_usd) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_amt_usd) AS p75
FROM orders;

-- 2. Create buckets using NTILE (4 buckets) based on total_amt_usd
SELECT
    id,
    account_id,
    total_amt_usd,
    NTILE(4) OVER (ORDER BY total_amt_usd) AS quartile_bucket
FROM orders
ORDER BY total_amt_usd DESC;
