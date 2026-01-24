-- ADVANCED JOINS & PERFORMANCE --

-- FULL OUTER JOIN --

-- 1. Return all accounts and all web_events even when no match exists.
-- NOTE: Useful for finding coverage gaps (accounts with no events OR events without accounts)
SELECT
    a.id AS account_id,
    a.name AS account_name,
    w.id AS web_event_id,
    w.channel,
    w.occurred_at
FROM accounts a
FULL OUTER JOIN web_events w
    ON a.id = w.account_id;

-- 2. Show only mismatch rows (coverage gaps)
SELECT
    a.id AS account_id,
    a.name AS account_name,
    w.account_id AS event_account_id,
    w.channel
FROM accounts a
FULL OUTER JOIN web_events w
    ON a.id = w.account_id
WHERE a.id IS NULL OR w.account_id IS NULL;


-- JOINS WITH COMPARISON OPERATORS --

-- 1. Join orders to accounts, but only keep “large” orders in the JOIN condition
SELECT
    o.id AS order_id,
    a.name AS account_name,
    o.total_amt_usd
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
   AND o.total_amt_usd > 5000
ORDER BY o.total_amt_usd DESC;

-- NOTE: Putting filters in ON vs WHERE can change results with OUTER JOINs.
-- Try the same with LEFT JOIN to see the difference.

SELECT
    a.name AS account_name,
    o.id AS order_id,
    o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
    ON a.id = o.account_id
   AND o.total_amt_usd > 5000
ORDER BY a.name;


-- SELF JOINS --

-- 1. Pair orders from the same account (avoid duplicates using o1.id < o2.id)
SELECT
    o1.account_id,
    o1.id AS order_1,
    o2.id AS order_2,
    o1.total_amt_usd AS amt_1,
    o2.total_amt_usd AS amt_2
FROM orders o1
JOIN orders o2
    ON o1.account_id = o2.account_id
   AND o1.id < o2.id
ORDER BY o1.account_id;


-- UNION --

-- 1. Unique list of account_ids that appear either in orders or web_events
SELECT account_id
FROM orders
UNION
SELECT account_id
FROM web_events;

-- 2. Keep duplicates (UNION ALL)
SELECT account_id
FROM orders
UNION ALL
SELECT account_id
FROM web_events;
