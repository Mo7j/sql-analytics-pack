-- SELECT & FORM Clauses -- 
SELECT * FROM orders; -- * to select all columns from the orders table
SELECT id, account_id, occurred_at FROM orders; -- selecting specific columns

-- LIMIT -- 
SELECT * FROM orders LIMIT 5; -- limiting results to 5 rows

-- ORDER BY Clause --
SELECT * FROM orders ORDER BY total_amt_usd LIMIT 100; -- ordering by total 
    -- note: default is ascending order 
SELECT * FROM orders ORDER BY total_amt_usd DESC LIMIT 100; -- ordering by total in descending order
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

-- WHERE Clause --
SELECT* FROM orders WHERE account_id = 1081 ORDER BY occurred_at DESC; -- where clause to filter by account_id


-- Practice Queries --

-- 1. Pulls the first 5 rows and all columns from the orders table that have a dollar amount of gloss_amt_usd greater than or equal to 1000.
SELECT * 
FROM orders 
WHERE gloss_amt_usd >= 1000 
LIMIT 5;

-- 2. Pulls the first 10 rows and all columns from the orders table that have a total_amt_usd less than 500.
SELECT *
FROM orders 
WHERE total_amt_usd < 500 
LIMIT 10;

-- 3. Filter the accounts table to include the company name, website, and the primary point of contact (primary_poc) just for the Exxon Mobil company in the accounts table.
SELECT name, website, primary_poc
FROM accounts 
WHERE name = 'Exxon Mobil';

-- Derived Column --
SELECT id, 
(standard_amt_usd/total_amt_usd)*100 AS std_percent, -- calculating percentage of standard amount to total amount and giving it an alias std_percent
 total_amt_usd 
FROM orders
LIMIT 10;

-- Practice Queries --

/* 
1. Create a column that divides the standard_amt_usd by the standard_qty
to find the unit price for standard paper for each order. Limit the results
to the first 10 orders, and include the id and account_id fields.
*/
SELECT id, account_id, 
(standard_amt_usd / standard_qty) AS standard_unit_price
FROM orders
LIMIT 10;

/* 
Write a query that finds the percentage of revenue that comes from 
poster paper for each order. You will need to use only the columns that
end with _usd. (Try to do this without using the total column.) Display 
the id and account_id fields also. 
*/
SELECT id, account_id, 
poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS post_per
FROM orders
LIMIT 10;