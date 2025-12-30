-- SELECT & FORM -- 
SELECT * FROM orders; -- * to select all columns from the orders table
SELECT id, account_id, occurred_at FROM orders; -- selecting specific columns

-- LIMIT -- 
SELECT * FROM orders LIMIT 5; -- limiting results to 5 rows

-- ORDER BY --
SELECT * FROM orders ORDER BY total LIMIT 100; -- ordering by total 
    -- note: default is ascending order 
SELECT * FROM orders ORDER BY total DESC LIMIT 100; -- ordering by total in descending order
    -- note: the order by comes after select and from but before limit


-- Practice Queries --

-- 1. Write a query to return the 10 earliest orders in the orders table. Include the id, occurred_at, and total_amt_usd.
SELECT id, occurred_at, total_amt_usd 
FROM orders 
ORDER BY occurred_at 
LIMIT 10;

-- 2. Write a query to return the top 5 orders in terms of largest total_amt_usd. Include the id, account_id, and total_amt_usd.
SELECT id, account_id, total_amt_usd 
FROM orders 
ORDER BY total_amt_usd DESC 
LIMIT 5;

-- 3. Write a query to return the lowest 20 orders in terms of smallest total_amt_usd. Include the id, account_id, and total_amt_usd.
SELECT id, account_id, total_amt_usd 
FROM orders 
ORDER BY total_amt_usd 
LIMIT 20;

-- ORDER BY Multiple Columns --
SELECT id, account_id, total_amt_usd FROM orders ORDER BY account_id, total_amt_usd DESC LIMIT 100;
    -- orders sorted first by account_id (ascending), then by total_amt_usd (descending)
    -- meaning that we are getting the highest orders for each account_id

SELECT id, account_id, total_amt_usd FROM orders ORDER BY total_amt_usd DESC, account_id;
    -- orders sorted first by total_amt_usd (descending), then by account_id (ascending)
    -- meaning that we are getting the accounts for the highest orders (but here since the prices are unique, the account_id ordering won't be very visible)

