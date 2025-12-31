-- INNER JOIN -- 
SELECT orders.*, accounts.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id; 
-- selecting all columns from both orders and accounts tables where there is a match on account_id

-- Practice Queries --
-- 1. Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website and the primary_poc from the accounts table.
SELECT orders.standard_qty, orders.gloss_qty, 
          orders.poster_qty,  accounts.website, 
          accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;
-- 2. Provide a table for all web_events associated with account name of Walmart. There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.
SELECT we.occurred_at, we.channel, a.name, a.primary_poc  
FROM accounts a
JOIN web_events we
ON we.account_id = a.id
WHERE a.name LIKE 'Walmart';

SELECT * FROM sales_reps;
SELECT * FROM region;
SELECT * FROM accounts;
-- 3. Provide a table that provides the region for each sales_rep along with their associated accounts. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
SELECT accounts.name account, sales_reps.name rep,  region.name region
FROM sales_reps
JOIN region
ON sales_reps.region_id = region.id
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id 
ORDER BY accounts.name;
-- 4. Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. Your final table should have 3 columns: region name, account name, and unit price. A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.
SELECT o.total_amt_usd/(o.total+0.01) unit_price, a.name name, r.name region
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id;

