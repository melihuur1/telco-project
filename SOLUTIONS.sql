-- SOLUTIONS.sql
-- ALTER SESSION SET CONTAINER = XEPDB1;
-- ALTER SESSION SET CURRENT_SCHEMA = telco_user;

/* ---------------------------------------------------------------------------
   1. Tariff-Based Customer Queries
--------------------------------------------------------------------------- */
-- 1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.
-- To identify customers subscribed to a specific tariff, an INNER JOIN operation is executed between the Customers and Tariffs tables utilizing the TARIFF_ID foreign key.
-- This join operation allows direct access to the textual name data of the tariff in the referenced table.
-- In the final execution step, a WHERE clause is applied to restrict the returned result set strictly to the 'Kobiye Destek' tariff name.

SELECT c.CUSTOMER_ID, c.NAME, c.CITY, c.SIGNUP_DATE, t.NAME AS TARIFF_NAME
FROM Customers c
INNER JOIN Tariffs t ON c.TARIFF_ID=t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek' ;

/*
|CUSTOMER_ID|NAME|CITY|SIGNUP_DATE|TARIFF_NAME|
|-----------|----|----|-----------|-----------|
|8970|Ahmet|SİVAS|2027-07-01 00:00:00.000|Kobiye Destek|
|8975|Tuğba|KIRŞEHİR|2027-06-04 00:00:00.000|Kobiye Destek|
|8979|Kadir|YOZGAT|2026-03-04 00:00:00.000|Kobiye Destek|
|8981|Zehra|MARDİN|2026-12-05 00:00:00.000|Kobiye Destek|
|8987|İsmail|BAYBURT|2027-02-04 00:00:00.000|Kobiye Destek|
|8999|Yasin|KARABÜK|2026-11-12 00:00:00.000|Kobiye Destek|
|9000|Adem|AKSARAY|2026-10-02 00:00:00.000|Kobiye Destek|
|9005|Fatih|RİZE|2027-07-01 00:00:00.000|Kobiye Destek|
|9007|Furkan|BİNGÖL|2025-06-06 00:00:00.000|Kobiye Destek|
|9013|Zehra|KIRŞEHİR|2026-10-07 00:00:00.000|Kobiye Destek|

*/

-- 1.2 Find the newest customer who subscribed to this tariff.
-- This query builds upon the previous filtering logic by applying a descending sort operation on the SIGNUP_DATE column.
-- By ordering the 'Kobiye Destek' customers in descending order, it is guaranteed that the most recently registered customer is positioned at the top of the dataset.
-- Utilizing the FETCH FIRST 1 ROWS ONLY command, which is standard in Oracle 12c and later versions, only a single row of data representing the newest record is extracted.

SELECT c.CUSTOMER_ID, c.NAME, c.CITY, c.SIGNUP_DATE, t.NAME AS TARIFF_NAME
FROM Customers c
INNER JOIN Tariffs t ON c.TARIFF_ID=t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROW ONLY ;

/*

|CUSTOMER_ID|NAME|CITY|SIGNUP_DATE|TARIFF_NAME|
|-----------|----|----|-----------|-----------|
|8798|Hatice|KARABÜK|2028-07-03 00:00:00.000|Kobiye Destek|

*/

/* ---------------------------------------------------------------------------
   2. Tariff Distribution
--------------------------------------------------------------------------- */
-- 2.1 Find the distribution of tariffs among the customers.
-- Calculating the distribution of tariffs requires the execution of an aggregate function over grouped data.
-- The joined dataset is partitioned using the GROUP BY operation based on the tariff name (t.NAME) column to isolate each distinct category.
-- Subsequently, the COUNT function is invoked to numerically compute the total number of customer records matching each unique tariff category.

SELECT t.NAME,COUNT(c.CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM Customers c
LEFT JOIN Tariffs t ON c.TARIFF_ID=t.TARIFF_ID
GROUP BY t.NAME ;

/*

|NAME|TOTAL_CUSTOMERS|
|----|---------------|
|Kobiye Destek|2483|
|Kurumsal SMS|2577|
|Genç Dinamik|2527|
|Çalışan GB|2413|

*/


/* ---------------------------------------------------------------------------
   3. Customer Signup Analysis
--------------------------------------------------------------------------- */
-- 3.1 Identify the earliest customers to sign up.
-- To locate the absolute earliest customers in the table, a subquery is initially written to compute the minimum registration date within the Customers table.
-- This derived minimum date value serves as a strict filtering criterion (WHERE SIGNUP_DATE = ...) for the primary query.
-- Consequently, the main query extracts all records where the registration date exactly matches this computed minimum value, identifying all initial customers who signed up on that day regardless of their ID sequence.

SELECT CUSTOMER_ID, NAME, CITY, SIGNUP_DATE
FROM Customers c
WHERE SIGNUP_DATE=(SELECT MIN(SIGNUP_DATE) FROM Customers) ;

/*

|CUSTOMER_ID|NAME|CITY|SIGNUP_DATE|
|-----------|----|----|-----------|
|9021|Kübra|GİRESUN|2025-01-05 00:00:00.000|
|9548|Havva|BARTIN|2025-01-05 00:00:00.000|
|9298|Serkan|BAYBURT|2025-01-05 00:00:00.000|
|8196|Havva|BİNGÖL|2025-01-05 00:00:00.000|
|7992|Furkan|ŞIRNAK|2025-01-05 00:00:00.000|
|7606|Burak|YOZGAT|2025-01-05 00:00:00.000|
|7336|Zehra|KAHRAMANMARAŞ|2025-01-05 00:00:00.000|
|7851|Hacer|ARDAHAN|2025-01-05 00:00:00.000|
|8877|Furkan|EDİRNE|2025-01-05 00:00:00.000|
|8765|Dilek|BATMAN|2025-01-05 00:00:00.000|

*/


-- 3.2 Find the distribution of these earliest customers across different cities, including the total count for each city.
-- This query utilizes the subquery structure from the previous phase to restrict the dataset exclusively to the earliest registered customers.
-- A GROUP BY operation is applied to the CITY column on this specifically filtered initial customer cohort to determine their geographical distribution.
-- The COUNT function is then utilized to output the exact frequency (total count) of these specific customers within each distinct city.

SELECT CITY,COUNT(c.CUSTOMER_ID) CUSTOMER_COUNT
FROM Customers c
WHERE SIGNUP_DATE=(SELECT MIN(SIGNUP_DATE) FROM Customers)
GROUP BY CITY ;

/*

|CITY|CUSTOMER_COUNT|
|----|--------------|
|GİRESUN|1|
|BARTIN|1|
|BAYBURT|1|
|BİNGÖL|1|
|ŞIRNAK|2|
|YOZGAT|1|
|KAHRAMANMARAŞ|1|
|ARDAHAN|1|
|EDİRNE|1|
|BATMAN|2|

*/

/* ---------------------------------------------------------------------------
   4. Missing Monthly Records
--------------------------------------------------------------------------- */
-- 4.1 Identify the IDs of these missing customers.
-- To detect customers lacking a record in the monthly statistics table, a LEFT JOIN is established between the Customers and Monthly_Stats tables via the CUSTOMER_ID.
-- This specific JOIN type preserves all records from the left table (Customers) while assigning NULL values in place of unmatched statistical records in the right table (Monthly_Stats).
-- The final WHERE block filters exclusively for these NULL conditions on the Monthly_Stats side, definitively isolating the IDs of the missing customers affected by the insertion error.

SELECT c.CUSTOMER_ID,c.NAME
FROM Customers c
LEFT JOIN Monthly_Stats m ON c.CUSTOMER_ID=m.CUSTOMER_ID 
WHERE m.CUSTOMER_ID IS NULL ;

/*

|CUSTOMER_ID|NAME|
|-----------|----|
|953|Ali|
|988|Esra|
|458|Metin|
|463|Osman|
|467|Hasan|
|205|Mahmut|
|211|Hasan|
|218|Merve|
|221|Merve|
|229|Elif|

*/

-- 4.2 Find the distribution of these missing customers across different cities.
-- A data clustering layer is appended to the LEFT JOIN and NULL verification architecture used for identifying records with missing data.
-- Once the customers proven to have missing data via the NULL check are isolated, the dataset is grouped by the city (CITY) column.
-- Following the grouping operation, the COUNT function is triggered to reveal the numerical city-based distribution of the customers impacted by the insertion error.

SELECT c.CITY,COUNT(c.CUSTOMER_ID) MISSING_RECORD_COUNT
FROM Customers c
LEFT JOIN Monthly_Stats m ON c.CUSTOMER_ID=m.CUSTOMER_ID 
WHERE m.CUSTOMER_ID IS NULL
GROUP BY c.CITY ;

/*

|CITY|MISSING_RECORD_COUNT|
|----|--------------------|
|İZMİR|2|
|SAMSUN|1|
|KONYA|1|
|ERZURUM|1|
|ESKİŞEHİR|1|
|OSMANİYE|3|
|ÇANKIRI|1|
|ŞIRNAK|1|
|KARABÜK|1|
|TEKİRDAĞ|1|

*/


/* ---------------------------------------------------------------------------
   5. Usage Analysis
--------------------------------------------------------------------------- */
-- 5.1 Find the customers who have used at least 75% of their data limit.
-- The Customers, Monthly_Stats, and Tariffs tables are connected via a multi-join operation to enable simultaneous access to consumption metrics and allocated limits.
-- The core algorithm relies on a dynamic lower-bound calculation logic within the WHERE clause, multiplying the tariff's data limit by 0.75.
-- Only customer records where the logged data usage (DATA_USAGE) is greater than or equal to this computed dynamic mathematical threshold are listed.
--By adding the condition (m.DATA_USAGE <> 0), records with zero data usage are filtered out, preventing incorrect results for tariffs that already have a data limit of zero.

SELECT c.CUSTOMER_ID, c.NAME, m.DATA_USAGE, t.DATA_LIMIT
FROM Customers c
INNER JOIN Monthly_Stats m ON c.CUSTOMER_ID=m.CUSTOMER_ID
INNER JOIN Tariffs t ON c.TARIFF_ID=t.TARIFF_ID
WHERE  m.DATA_USAGE <> 0 AND m.DATA_USAGE >= (t.DATA_LIMIT*0.75) ;

/*

|CUSTOMER_ID|NAME|DATA_USAGE|DATA_LIMIT|
|-----------|----|----------|----------|
|8970|Ahmet|19079.55|20480|
|8974|Emine|9727.16|10240|
|8981|Zehra|18491.95|20480|
|8988|Meryem|17503.1|20480|
|9006|Ömer|9254.38|10240|
|9020|İbrahim|17740.74|20480|
|9022|Havva|16099.44|20480|
|9025|Zeynep|18564.75|20480|
|9028|Meryem|19260.17|20480|
|9052|Ali|9461.14|10240|

*/

-- 5.2 Identify the customers who have completely exhausted all of their package limits.
-- Determining whether all limits are completely exhausted requires the simultaneous evaluation of three different usage metrics (data, minutes, and SMS) against their respective tariff maximums.
-- Multiple conditional statements combined with the AND logical operator are defined within the WHERE block to enforce strict compliance across all resource types.
-- A customer's result is returned solely if their tracked data, minute, and SMS usage all equate to or exceed the absolute limits in their defined tariff profile.
SELECT c.CUSTOMER_ID, c.NAME, t.NAME AS TARIFF_NAME
FROM Customers c
INNER JOIN Monthly_Stats m ON c.CUSTOMER_ID=m.CUSTOMER_ID
INNER JOIN Tariffs t ON c.TARIFF_ID=t.TARIFF_ID
WHERE m.DATA_USAGE>=t.DATA_LIMIT 
  AND m.SMS_USAGE>=t.SMS_LIMIT 
  AND m.MINUTE_USAGE>=t.MINUTE_LIMIT ;

  /*
  The query returned no rows.
  */

/* ---------------------------------------------------------------------------
   6. Payment Analysis
--------------------------------------------------------------------------- */

-- 6.1 Find the customers who have unpaid fees.
-- Retrieving customers with pending debts requires an INNER JOIN operation linking customer profiles with their respective billing statuses.
-- The query executes a direct string matching operation on the PAYMENT_STATUS column, which is constrained within the schema design.
-- By explicitly filtering for the 'UNPAID' string in the WHERE clause, the specific individuals holding a pending monthly payment obligation are isolated in the result set.

SELECT c.CUSTOMER_ID, c.NAME, m.PAYMENT_STATUS
FROM Customers c
INNER JOIN Monthly_Stats m ON c.CUSTOMER_ID=m.CUSTOMER_ID
WHERE m.PAYMENT_STATUS='UNPAID';

/*

|CUSTOMER_ID|NAME|PAYMENT_STATUS|
|-----------|----|--------------|
|8970|Ahmet|UNPAID|
|8971|Songül|UNPAID|
|8975|Tuğba|UNPAID|
|8976|Özlem|UNPAID|
|8977|Burak|UNPAID|
|8986|Ömer|UNPAID|
|9006|Ömer|UNPAID|
|9026|Rabia|UNPAID|
|9027|Aynur|UNPAID|
|9030|Ali|UNPAID|

*/

-- 6.2 Find the distribution of all payment statuses across the different tariffs.
-- To parse payment behaviors across service tiers, tariffs and statistical payment data are mapped through a three-way JOIN over the customer table.
-- The GROUP BY block is structured utilizing two distinct dimensions: the direct tariff name and the textual payment status (PAYMENT_STATUS).
-- This multidimensional grouping strategy enables the COUNT function to compute the exact frequency of different payment statuses within each unique tariff.

SELECT t.NAME AS TARIFF_NAME, m.PAYMENT_STATUS, COUNT(c.CUSTOMER_ID) AS STATUS_COUNT
FROM Customers c
INNER JOIN Monthly_Stats m ON c.CUSTOMER_ID = m.CUSTOMER_ID
INNER JOIN Tariffs t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME, m.PAYMENT_STATUS
ORDER BY t.NAME, m.PAYMENT_STATUS;

/*

|TARIFF_NAME|PAYMENT_STATUS|STATUS_COUNT|
|-----------|--------------|------------|
|Genç Dinamik|LATE|372|
|Genç Dinamik|PAID|1792|
|Genç Dinamik|UNPAID|352|
|Kobiye Destek|LATE|392|
|Kobiye Destek|PAID|1719|
|Kobiye Destek|UNPAID|360|
|Kurumsal SMS|LATE|368|
|Kurumsal SMS|PAID|1796|
|Kurumsal SMS|UNPAID|403|
|Çalışan GB|LATE|365|

*/