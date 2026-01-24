/*
Project Title: Coverage Gaps, Account Reach & Join Strategy Analysis

Your Role:
You are a junior data analyst tasked with identifying data coverage gaps,
relationship mismatches, and performance risks using advanced joins.

Constraints:
You may use ONLY:
SELECT, FROM, JOIN (INNER, LEFT, RIGHT, FULL),
UNION,
Self JOINs,
Comparison operators in JOIN conditions

NO window functions
*/


-- ===================================================
-- Business Question 1:
-- Are there accounts with no web engagement or web activity
-- not linked to valid accounts?
-- ===================================================

SELECT
    a.id AS account_id,
    a.name AS account_name,
    w.channel
FROM accounts a
FULL OUTER JOIN web_events w
    ON a.id = w.account_id
WHERE a.id IS NULL
   OR w.account_id IS NULL;


-- ===================================================
-- Business Question 2:
-- Identify accounts that placed orders but never had web events.
-- ===================================================

SELECT DISTINCT
    a.id AS account_id,
    a.name AS account_name
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
LEFT JOIN web_events w
    ON a.id = w.account_id
WHERE w.id IS NULL;


-- ===================================================
-- Business Question 3:
-- Identify accounts with web engagement but no orders.
-- ===================================================

SELECT DISTINCT
    a.id AS account_id,
    a.name AS account_name
FROM accounts a
JOIN web_events w
    ON a.id = w.account_id
LEFT JOIN orders o
    ON a.id = o.account_id
WHERE o.id IS NULL;


-- ===================================================
-- Business Question 4:
-- Compare order pairs within the same account
-- to identify duplicated or split purchasing behavior.
-- ===================================================

SELECT
    o1.account_id,
    o1.id AS order_1,
    o2.id AS order_2,
    o1.total_amt_usd AS order_1_amt,
    o2.total_amt_usd AS order_2_amt
FROM orders o1
JOIN orders o2
    ON o1.account_id = o2.account_id
   AND o1.id < o2.id
ORDER BY o1.account_id;


-- ===================================================
-- Business Question 5:
-- Create a unified list of all accounts that either
-- placed orders or had web engagement.
-- ===================================================

SELECT account_id FROM orders
UNION
SELECT account_id FROM web_events;
