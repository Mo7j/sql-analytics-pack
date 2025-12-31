-- IS NULL & IS NOT NULL --
SELECT *
FROM accounts
WHERE primary_poc IS NULL; -- Selects all accounts where the primary point of contact is not assigned

SELECT *
FROM accounts
WHERE primary_poc IS NOT NULL; -- Selects all accounts where the primary point of contact is assigned

-- COUNT --
SELECT COUNT(*) AS order_count FROM orders; -- Counts the total number of orders
-- NOTE: COUNT(column_name) counts only non-null values in that column

-- SUM --
SELECT SUM(total_amt_usd) AS total_revenue FROM orders; -- Sums up the total revenue from all orders

SELECT SUM(standard_qty) AS standard,SUM(poster_qty) AS poster,
SUM(gloss_qty) AS gloss FROM orders;
-- Sums up the quantities of different product types from all orders

-- practice query --
-- 1. Find the total amount of poster_qty paper ordered in the orders table.
SELECT SUM(poster_qty)  AS total_posters_sales FROM orders;
-- 2. Find the total amount of standard_qty paper ordered in the orders table.
SELECT SUM(standard_qty)  AS total_standard_sales FROM orders;
-- 3. Find the total dollar amount of sales using the total_amt_usd in the orders table.
SELECT SUM(total_amt_usd)  AS total_dollar_sales FROM orders;
-- 4. Find the total amount for each individual order that was spent on standard and gloss paper in the orders table. This should give a dollar amount for each order in the table.
SELECT account_id, standard_amt_usd + gloss_amt_usd AS total_amount_s_p FROM orders;
-- 5. Though the price/standard_qty paper varies from one order to the next. I would like this ratio across all of the sales made in the orders table.
SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit FROM orders;

-- MIN & MAX & AVERAGE --
-- 1. When was the earliest order ever placed?
SELECT MIN(occurred_at) AS first_order_date FROM orders; 
-- 2. Try performing the same query as in question 1 without using an aggregation function.
SELECT occurred_at FROM orders ORDER BY occurred_at LIMIT 1;
-- 3. When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at) AS last_event_date FROM web_events;
-- 4. Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at FROM web_events ORDER BY occurred_at DESC LIMIT 1;
-- 5. Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.
SELECT AVG(standard_amt_usd) AS avg_standard_price,
    AVG(gloss_amt_usd) AS avg_gloss_price,
    AVG(poster_amt_usd) AS avg_poster_price,
    AVG(standard_qty) AS avg_standard_qty,
    AVG(gloss_qty) AS avg_gloss_qty,
    AVG(poster_qty) AS avg_poster_qty
FROM orders;
-- 6. Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders? Note, this is more advanced than the topics we have covered thus far to build a general solution, but we can hard code a solution in the following way.
SELECT *
FROM (SELECT total_amt_usd
         FROM orders
         ORDER BY total_amt_usd
         LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2; -- There are 6913 orders, so the median is the average of the 3456th and 3457th values.

-- GROUP BY --
-- 1. Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
SELECT a.name, o.occurred_at 
FROM accounts a
JOIN orders o ON a.id = o.account_id
ORDER BY o.occurred_at LIMIT 1;
-- 2. Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.
SELECT SUM(o.total_amt_usd), a.name
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY a.name;
-- 3. Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.
SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a ON w.account_id = a.id
ORDER BY w.occurred_at DESC LIMIT 1;
-- 4. Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.
SELECT w.channel, COUNT(*) AS channel_count
FROM web_events w
GROUP BY w.channel;
-- 5. Who was the primary contact associated with the earliest web_event?
SELECT a.primary_poc
FROM accounts a
JOIN web_events w ON a.id = w.account_id
ORDER BY w.occurred_at LIMIT 1;
-- 6. What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.
SELECT a.name, MIN(o.total_amt_usd) AS smallest_order
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;
-- 7. Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps.
SELECT r.name, COUNT(*) num_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_reps;