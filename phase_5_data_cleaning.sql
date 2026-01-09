-- LEFT & RIGHT --

-- 1. In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here(opens in a new tab). Pull these extensions and provide how many of each website type exist in the accounts table.
SELECT RIGHT(website, 3) AS domain, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- 2. There is much debate about how much the name (or even the first letter of a company name)(opens in a new tab) matters. Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).
SELECT LEFT(UPPER(name), 1) AS first_letter, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second group of those company names that start with a letter. What proportion of company names start with a letter?
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 1 ELSE 0 END AS num, 
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;

-- 4. Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                           THEN 1 ELSE 0 END AS vowels, 
             CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                          THEN 0 ELSE 1 END AS other
            FROM accounts) t1;

-- POSITION & STRPOS --

-- 1. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, 
   RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;

-- 2. Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.
SELECT LEFT(name, STRPOS(name, ' ') -1 ) first_name, 
          RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) last_name
FROM sales_reps;

-- CONCAT -- 

-- 1. Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
WITH t1 AS (
    SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
    FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;

-- 2. You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise your solution should be just as in question 1.
WITH t1 AS (
    SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
    FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;

-- 3. We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.
WITH t1 AS (
    SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
    FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

-- CAST -- 
-- Used to explicitly convert a value from one data type to another

-- 1. Cast total_amt_usd from numeric to integer (rounds down).
SELECT id,
       total_amt_usd,
       CAST(total_amt_usd AS INTEGER) AS total_amt_int
FROM orders
LIMIT 10;

-- 2. Cast occurred_at to DATE only (remove time component).
SELECT id,
       occurred_at,
       CAST(occurred_at AS DATE) AS order_date
FROM orders
LIMIT 10;

-- 3. Calculate unit price and cast the result to NUMERIC with 2 decimals.
SELECT id,
       account_id,
       CAST(standard_amt_usd / (standard_qty + 0.01) AS NUMERIC(10,2)) AS standard_unit_price
FROM orders
LIMIT 10;

-- 4. Cast year extracted from date to INTEGER (explicit, even though DATE_PART returns numeric).
SELECT id,
       CAST(DATE_PART('year', occurred_at) AS INTEGER) AS order_year
FROM orders
LIMIT 10;

-- 5. Cast total order quantity to TEXT (useful for concatenation later).
SELECT id,
       CAST(total AS TEXT) AS total_items_text
FROM orders
LIMIT 10;


-- COALESCE --
-- Used to replace NULL values with a default value

-- 1. Replace NULL primary_poc values with 'Unknown Contact'.
SELECT id,
       name,
       COALESCE(primary_poc, 'Unknown Contact') AS primary_poc_clean
FROM accounts;

-- 2. Replace NULL web_event channels with 'No Event'.
SELECT a.name,
       COALESCE(w.channel, 'No Event') AS channel
FROM accounts a
LEFT JOIN web_events w
    ON a.id = w.account_id;

-- 3. Prevent NULL totals when summing order amounts (safe aggregation).
SELECT a.name,
       COALESCE(SUM(o.total_amt_usd), 0) AS total_spent
FROM accounts a
LEFT JOIN orders o
    ON a.id = o.account_id
GROUP BY a.name;

-- 4. Handle NULL quantities before calculations.
SELECT id,
       COALESCE(standard_qty, 0) AS standard_qty_clean,
       COALESCE(gloss_qty, 0) AS gloss_qty_clean,
       COALESCE(poster_qty, 0) AS poster_qty_clean
FROM orders
LIMIT 10;

-- 5. Combine CAST and COALESCE together (very common in real analysis).
-- Replace NULL total_amt_usd with 0, then cast to INTEGER.
SELECT id,
       CAST(COALESCE(total_amt_usd, 0) AS INTEGER) AS total_amt_int_safe
FROM orders
LIMIT 10;

-- 6. Use COALESCE to create a fallback contact name.
SELECT name,
       COALESCE(primary_poc, 'No Primary Contact Assigned') AS contact_name
FROM accounts;
