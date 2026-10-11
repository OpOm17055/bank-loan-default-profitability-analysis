-- Bank Loan Default & Profitability Analysis
-- Lending Club finished loans (2007-2018), cleaned in Python -> loans_clean.csv
-- MySQL
--
-- Note: default rate / return queries use matured loans only (is_matured = 1).
-- For 2016-2018, most finished loans are defaults since the good ones are still
-- running, so using all loans makes risk look higher than it is (19.98% vs 15.19%).


/* ---------------- Part A: create table + load data ---------------- */

CREATE DATABASE IF NOT EXISTS bank_loan;
USE bank_loan;

DROP TABLE IF EXISTS loans;
CREATE TABLE loans (
    id                  BIGINT PRIMARY KEY,
    issue_date          DATE NOT NULL,
    issue_year          SMALLINT NOT NULL,
    issue_month         TINYINT NOT NULL,
    loan_amnt           DECIMAL(12,2) NOT NULL,
    funded_amnt         DECIMAL(12,2) NOT NULL,
    term_months         TINYINT NOT NULL,          -- 36 / 60
    int_rate            DECIMAL(5,2),              -- in %, e.g. 13.56
    installment         DECIMAL(10,2),
    grade               CHAR(1),                   -- A (safest) to G
    sub_grade           CHAR(2),
    purpose             VARCHAR(30),
    loan_status         VARCHAR(15),               -- Fully Paid / Charged Off
    is_default          TINYINT NOT NULL,          -- 1 = Charged Off
    is_matured          TINYINT NOT NULL,          -- 1 = term ended before Mar 2019
    total_pymnt         DECIMAL(12,2),
    total_rec_prncp     DECIMAL(12,2),
    total_rec_int       DECIMAL(12,2),
    recoveries          DECIMAL(12,2),
    net_profit          DECIMAL(12,2),             -- total_pymnt - funded_amnt
    annual_inc          DECIMAL(14,2),
    income_band         VARCHAR(10),
    emp_length_yrs      TINYINT,                   -- NULL = not given
    home_ownership      VARCHAR(10),
    verification_status VARCHAR(20),
    addr_state          CHAR(2),
    dti                 DECIMAL(5,2),
    dti_band            VARCHAR(10),
    fico_avg            DECIMAL(5,1),
    fico_band           VARCHAR(10),
    delinq_2yrs         SMALLINT,
    inq_last_6mths      SMALLINT,
    open_acc            SMALLINT,
    pub_rec             SMALLINT,
    revol_util          DECIMAL(6,2),
    application_type    VARCHAR(15)
);

-- change path before running
-- blank cells go through @vars + NULLIF, otherwise MySQL loads them as 0
LOAD DATA LOCAL INFILE 'C:/Users/YourName/Downloads/loans_clean.csv'
INTO TABLE loans
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, issue_date, issue_year, issue_month, loan_amnt, funded_amnt, term_months,
 @int_rate, @installment, grade, sub_grade, purpose, loan_status, is_default,
 is_matured, @total_pymnt, @total_rec_prncp, @total_rec_int, @recoveries,
 @net_profit, @annual_inc, @income_band, @emp_length_yrs, home_ownership,
 verification_status, addr_state, @dti, @dti_band, @fico_avg, @fico_band,
 @delinq_2yrs, @inq_last_6mths, @open_acc, @pub_rec, @revol_util, @application_type)
SET
    int_rate         = NULLIF(@int_rate, ''),
    installment      = NULLIF(@installment, ''),
    total_pymnt      = NULLIF(@total_pymnt, ''),
    total_rec_prncp  = NULLIF(@total_rec_prncp, ''),
    total_rec_int    = NULLIF(@total_rec_int, ''),
    recoveries       = NULLIF(@recoveries, ''),
    net_profit       = NULLIF(@net_profit, ''),
    annual_inc       = NULLIF(@annual_inc, ''),
    income_band      = NULLIF(@income_band, ''),
    emp_length_yrs   = ROUND(NULLIF(@emp_length_yrs, '')),
    dti              = NULLIF(@dti, ''),
    dti_band         = NULLIF(@dti_band, ''),
    fico_avg         = NULLIF(@fico_avg, ''),
    fico_band        = NULLIF(@fico_band, ''),
    delinq_2yrs      = ROUND(NULLIF(@delinq_2yrs, '')),
    inq_last_6mths   = ROUND(NULLIF(@inq_last_6mths, '')),
    open_acc         = ROUND(NULLIF(@open_acc, '')),
    pub_rec          = ROUND(NULLIF(@pub_rec, '')),
    revol_util       = NULLIF(@revol_util, ''),
    application_type = NULLIF(TRIM(TRAILING '\r' FROM @application_type), '');

CREATE INDEX idx_grade   ON loans (grade);
CREATE INDEX idx_year    ON loans (issue_year);
CREATE INDEX idx_purpose ON loans (purpose);
CREATE INDEX idx_state   ON loans (addr_state);

-- check: should match the Python output
-- 1,348,059 rows | $19,412,303,675 funded | 19.98% default | 15.19% matured
SELECT
    COUNT(*)                                        AS total_loans,
    SUM(funded_amnt)                                AS total_funded,
    ROUND(AVG(is_default) * 100, 2)                 AS default_rate_pct,
    ROUND(AVG(CASE WHEN is_matured = 1 THEN is_default END) * 100, 2) AS matured_default_rate_pct,
    MIN(issue_date)                                 AS first_loan,
    MAX(issue_date)                                 AS last_loan
FROM loans;

SELECT grade, COUNT(*) AS loans, ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM loans
GROUP BY grade
ORDER BY grade;


/* ---------------- Part B: business questions ---------------- */

CREATE OR REPLACE VIEW matured_loans AS
SELECT * FROM loans WHERE is_matured = 1;


-- Q1. Portfolio overview
SELECT
    COUNT(*)                                          AS total_loans,
    ROUND(SUM(funded_amnt) / 1e9, 2)                  AS funded_bn,
    ROUND(SUM(total_pymnt) / 1e9, 2)                  AS received_bn,
    ROUND(AVG(int_rate), 2)                           AS avg_int_rate_pct,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(CASE WHEN is_default = 1 THEN funded_amnt - total_pymnt END) / 1e9, 2)
                                                      AS lost_on_defaults_bn,
    ROUND(SUM(net_profit) / SUM(funded_amnt) * 100, 2) AS return_on_funded_pct
FROM matured_loans;
-- 779,025 loans, $10.30B lent, $11.24B back, 15.19% default, $0.57B lost, +9.18% return


-- Q2. Does a higher grade (higher rate) cover the extra defaults?
SELECT
    grade,
    COUNT(*)                                            AS loans,
    ROUND(AVG(int_rate), 2)                             AS avg_int_rate_pct,
    ROUND(AVG(is_default) * 100, 1)                     AS default_rate_pct,
    ROUND(SUM(net_profit) / SUM(funded_amnt) * 100, 2)  AS return_pct
FROM matured_loans
GROUP BY grade
ORDER BY grade;
-- default goes 5.5% (A) -> 38.9% (G), return seems to rise with grade (7.1% -> 14.3%)
-- but risky grades have more 60m loans = 5 yrs of interest. checked in Q2b


-- Q2b. Same, 36-month loans only
SELECT
    grade,
    COUNT(*)                                            AS loans,
    ROUND(AVG(int_rate), 2)                             AS avg_int_rate_pct,
    ROUND(AVG(is_default) * 100, 1)                     AS default_rate_pct,
    ROUND(SUM(net_profit) / SUM(funded_amnt) * 100, 2)  AS return_pct
FROM matured_loans
WHERE term_months = 36
GROUP BY grade
ORDER BY grade;
-- return peaks at B (8.60%) then drops to 0.08% at G (41.2% default)
-- -> risk is under-priced after grade B


-- Q3. 36 vs 60 month
SELECT
    term_months,
    COUNT(*)                                            AS loans,
    ROUND(AVG(int_rate), 2)                             AS avg_int_rate_pct,
    ROUND(AVG(is_default) * 100, 1)                     AS default_rate_pct,
    ROUND(SUM(net_profit) / SUM(funded_amnt) * 100, 2)  AS return_pct
FROM matured_loans
GROUP BY term_months;
-- 60m: 25.4% default vs 14.2% for 36m

-- within each grade (so it's not just riskier people taking 60m)
SELECT
    grade,
    ROUND(AVG(CASE WHEN term_months = 36 THEN is_default END) * 100, 1) AS default_36m_pct,
    ROUND(AVG(CASE WHEN term_months = 60 THEN is_default END) * 100, 1) AS default_60m_pct
FROM matured_loans
GROUP BY grade
ORDER BY grade;
-- 60m worse in A-F (A: 8.3 vs 5.5), only G flips (small sample)


-- Q4. Loss by purpose
WITH by_purpose AS (
    SELECT
        purpose,
        COUNT(*)                                    AS loans,
        AVG(is_default)                             AS default_rate,
        SUM(CASE WHEN is_default = 1 THEN funded_amnt - total_pymnt ELSE 0 END) AS loss_amt
    FROM matured_loans
    GROUP BY purpose
)
SELECT
    purpose,
    loans,
    ROUND(default_rate * 100, 1)                         AS default_rate_pct,
    ROUND(loss_amt / 1e6, 1)                             AS loss_mn,
    ROUND(loss_amt / SUM(loss_amt) OVER () * 100, 1)     AS share_of_losses_pct,
    RANK() OVER (ORDER BY default_rate DESC)             AS risk_rank
FROM by_purpose
WHERE loans >= 1000
ORDER BY default_rate DESC;
-- debt_consolidation = 62.6% of all losses ($356.8M)
-- small_business has the highest default (24.6%), car the lowest (12.1%)


-- Q5. Income, DTI, FICO
SELECT income_band, COUNT(*) AS loans, ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM matured_loans WHERE income_band IS NOT NULL
GROUP BY income_band
ORDER BY MIN(annual_inc);
-- <40K 19.5% ... 150K+ 10.4%

SELECT dti_band, COUNT(*) AS loans, ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM matured_loans WHERE dti_band IS NOT NULL
GROUP BY dti_band
ORDER BY MIN(dti);
-- 0-10: 11.7%, 30+: 21.3%

SELECT fico_band, COUNT(*) AS loans, ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM matured_loans WHERE fico_band IS NOT NULL
GROUP BY fico_band
ORDER BY MIN(fico_avg);
-- 660-699: 18.1%, 780+: 4.7%  (<660 only has 489 loans, ignore)


-- Q6. Home ownership, employment length
SELECT home_ownership, COUNT(*) AS loans, ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM matured_loans
GROUP BY home_ownership
ORDER BY default_rate_pct DESC;
-- rent 17.6%, mortgage 13.0%

SELECT COALESCE(CAST(emp_length_yrs AS CHAR), 'Unknown') AS emp_length,
       COUNT(*) AS loans, ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM matured_loans
GROUP BY emp_length_yrs
ORDER BY emp_length_yrs;
-- 0-10 yrs all around 14-15.5%, but Unknown = 21.4%


-- Q7. Verified vs not verified income
SELECT verification_status, COUNT(*) AS loans,
       ROUND(AVG(int_rate), 2) AS avg_int_rate_pct,
       ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM matured_loans
GROUP BY verification_status;
-- verified 18.3% vs not verified 11.8%, opposite of what you'd expect

-- Q7b. is that just because verified loans are lower grades?
SELECT
    grade,
    ROUND(AVG(CASE WHEN verification_status = 'Not Verified'    THEN is_default END) * 100, 1) AS not_verified_pct,
    ROUND(AVG(CASE WHEN verification_status = 'Source Verified' THEN is_default END) * 100, 1) AS source_verified_pct,
    ROUND(AVG(CASE WHEN verification_status = 'Verified'        THEN is_default END) * 100, 1) AS verified_pct
FROM matured_loans
GROUP BY grade
ORDER BY grade;
-- no, verified is higher in every grade (C: 16.7 vs 19.6)


-- Q8. Top 10 states by default rate (5000+ loans)
SELECT addr_state,
       COUNT(*) AS loans,
       ROUND(AVG(is_default) * 100, 1) AS default_rate_pct,
       ROUND(SUM(net_profit) / SUM(funded_amnt) * 100, 2) AS return_pct
FROM matured_loans
GROUP BY addr_state
HAVING COUNT(*) >= 5000
ORDER BY default_rate_pct DESC
LIMIT 10;
-- AR 18.5, AL 18.2, NV 18.1. only ~3 pts above avg, state isn't a big driver


-- Q9. Yearly volume (all loans) + default (matured)
SELECT
    issue_year,
    COUNT(*)                                                   AS loans_issued,
    ROUND(SUM(funded_amnt) / 1e6, 0)                           AS funded_mn,
    ROUND(AVG(CASE WHEN is_matured = 1 THEN is_default END) * 100, 1) AS matured_default_rate_pct,
    ROUND((COUNT(*) / LAG(COUNT(*)) OVER (ORDER BY issue_year) - 1) * 100, 0) AS yoy_growth_pct
FROM loans
GROUP BY issue_year
ORDER BY issue_year;
-- 2007: 603 loans ($5M) -> 2015: 375,545 ($5.5B)
-- 2008 cohort 20.7% default, then 13.7-16.2% from 2009
-- 2016-18 drop is because current loans were removed, not a real decline


-- Q10. Return by sub-grade, does any segment lose money?
WITH sg AS (
    SELECT
        sub_grade,
        COUNT(*)                                            AS loans,
        AVG(int_rate)                                       AS avg_rate,
        AVG(is_default)                                     AS default_rate,
        SUM(net_profit) / SUM(funded_amnt)                  AS ret
    FROM matured_loans
    GROUP BY sub_grade
)
SELECT
    sub_grade, loans,
    ROUND(avg_rate, 2)          AS avg_int_rate_pct,
    ROUND(default_rate * 100, 1) AS default_rate_pct,
    ROUND(ret * 100, 2)         AS return_pct,
    CASE WHEN ret < 0 THEN 'Loses money' ELSE 'Profitable' END AS verdict
FROM sg
ORDER BY sub_grade;
-- none negative overall, but rates flatten ~24-25% from F3 to G5 while default keeps rising to ~40%
