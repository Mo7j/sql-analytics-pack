/*
Project Title: Data Cleaning, Standardization & Contact Quality Checks (SQL)

Your Role:
You are a junior data analyst tasked with preparing customer and activity data
for reliable reporting by cleaning text fields, standardizing formats,
and surfacing potential data quality risks.

Constraints:
You may use ONLY:
SELECT, FROM, JOIN, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT,
String functions (LEFT, RIGHT, LENGTH, STRPOS/POSITION, REPLACE),
CONCAT and ||,
CAST,
COALESCE,
CASE statements

NO window functions
*/


-- ===================================================
-- Business Question 1:
-- What website domains do customers use, and is our dataset dominated
-- by a small number of domain types?
--
-- Why this matters:
-- Domain patterns can indicate customer segments and reduce reporting errors
-- when standardizing URLs or building contact pipelines.
-- ===================================================

SELECT
    RIGHT(website, 3) AS domain,
    COUNT(*) AS num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;


-- ===================================================
-- Business Question 2:
-- Do account names start mostly with letters or numbers?
-- (basic normalization check for naming conventions)
--
-- Why this matters:
-- Many downstream processes assume alphabetic names (sorting, grouping,
-- entity matching). Numeric-leading names can break naive rules.
-- ===================================================

SELECT
    SUM(is_number) AS num_starting_with_number,
    SUM(is_letter) AS num_starting_with_letter
FROM (
    SELECT
        CASE
            WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 1
            ELSE 0
        END AS is_number,
        CASE
            WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 0
            ELSE 1
        END AS is_letter
    FROM accounts
) t1;


-- ===================================================
-- Business Question 3:
-- What proportion of account names start with a vowel vs something else?
--
-- Why this matters:
-- This is a simple categorical quality check useful for validating
-- string logic and identifying odd naming patterns.
-- ===================================================

SELECT
    SUM(is_vowel) AS starts_with_vowel,
    SUM(is_other) AS starts_with_other
FROM (
    SELECT
        CASE
            WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') THEN 1
            ELSE 0
        END AS is_vowel,
        CASE
            WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') THEN 0
            ELSE 1
        END AS is_other
    FROM accounts
) t1;


-- ===================================================
-- Business Question 4:
-- Can we reliably split primary contacts into first/last names?
-- Surface potential formatting issues.
--
-- Why this matters:
-- Contact normalization is foundational for CRM sync, emailing,
-- deduplication, and analytics by contact.
-- ===================================================

SELECT
    a.id AS account_id,
    a.name AS account_name,
    a.primary_poc,
    LEFT(a.primary_poc, STRPOS(a.primary_poc, ' ') - 1) AS first_name,
    RIGHT(a.primary_poc, LENGTH(a.primary_poc) - STRPOS(a.primary_poc, ' ')) AS last_name
FROM accounts a
WHERE a.primary_poc IS NOT NULL
  AND STRPOS(a.primary_poc, ' ') > 0
ORDER BY a.id
LIMIT 50;


-- ===================================================
-- Business Question 5:
-- Generate cleaned email addresses for primary contacts:
-- first.last@company.com, removing spaces from company names.
--
-- Why this matters:
-- Email formats must be standardized to avoid downstream failures
-- in outreach tools and automated pipelines.
-- ===================================================

WITH names AS (
    SELECT
        id AS account_id,
        name AS account_name,
        primary_poc,
        LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name,
        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name
    FROM accounts
    WHERE primary_poc IS NOT NULL
      AND STRPOS(primary_poc, ' ') > 0
)
SELECT
    account_id,
    account_name,
    first_name,
    last_name,
    CONCAT(
        LOWER(first_name), '.', LOWER(last_name),
        '@',
        REPLACE(LOWER(account_name), ' ', ''),
        '.com'
    ) AS email_clean
FROM names
ORDER BY account_id
LIMIT 50;


-- ===================================================
-- Business Question 6:
-- Generate initial passwords based on a consistent rule:
-- first/last initials + name lengths + COMPANY (uppercase, no spaces).
--
-- Why this matters:
-- This tests string manipulation and enforces consistent formatting rules
-- for identity-related fields (even if only for internal onboarding).
-- ===================================================

WITH names AS (
    SELECT
        id AS account_id,
        name AS account_name,
        primary_poc,
        LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name,
        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name
    FROM accounts
    WHERE primary_poc IS NOT NULL
      AND STRPOS(primary_poc, ' ') > 0
)
SELECT
    account_id,
    account_name,
    first_name,
    last_name,
    LEFT(LOWER(first_name), 1)
        || RIGHT(LOWER(first_name), 1)
        || LEFT(LOWER(last_name), 1)
        || RIGHT(LOWER(last_name), 1)
        || LENGTH(first_name)
        || LENGTH(last_name)
        || REPLACE(UPPER(account_name), ' ', '') AS initial_password
FROM names
ORDER BY account_id
LIMIT 50;


-- ===================================================
-- Business Question 7:
-- Standardize numeric/date fields and prevent NULL issues:
-- - Cast occurred_at to DATE
-- - Safe unit price with numeric rounding
-- - Safe totals using COALESCE
--
-- Why this matters:
-- Dashboards and exports often fail due to NULLs or inconsistent types.
-- These fixes make metrics stable and predictable.
-- ===================================================

SELECT
    o.id AS order_id,
    o.account_id,
    CAST(o.occurred_at AS DATE) AS order_date,
    CAST(COALESCE(o.total_amt_usd, 0) AS INTEGER) AS total_amt_usd_int_safe,
    CAST(o.standard_amt_usd / (COALESCE(o.standard_qty, 0) + 0.01) AS NUMERIC(10,2)) AS standard_unit_price_2dp
FROM orders o
ORDER BY o.id
LIMIT 50;


-- ===================================================
-- Business Question 8:
-- Data completeness check:
-- Which accounts have missing primary contacts?
--
-- Why this matters:
-- Missing contacts reduce sales effectiveness and break outreach workflows.
-- ===================================================

SELECT
    id AS account_id,
    name AS account_name,
    COALESCE(primary_poc, 'No Primary Contact Assigned') AS primary_poc_clean
FROM accounts
WHERE primary_poc IS NULL
ORDER BY name;
