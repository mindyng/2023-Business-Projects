WITH transaction_num AS (
SELECT *
, ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY transaction_date) AS tx_num
FROM public.saas_cust_transactions
ORDER BY cust_id, transaction_date
)

, specific_tx AS (
SELECT *
FROM transaction_num
WHERE tx_num <5
)

-- SELECT cust_id, transaction_date
-- FROM specific_tx
-- WHERE cust_id
-- IN (SELECT cust_id
-- FROM specific_tx
-- WHERE tx_num = 4)
-- ORDER BY cust_id, transaction_date

-- SELECT *
-- FROM
-- (
SELECT t1.cust_id
, t1.transaction_type AS transaction_type1
, t1.subscription_type AS subscription_type1
, t1.subscription_price AS subscription_price1
, t1.customer_gender AS customer_gender1
, t1.age_group AS age_group1
, t1.customer_country AS customer_country1
, t1.referral_type AS referral_type1

, t2.transaction_type AS transaction_type2
, t2.subscription_type AS subscription_type2
, t2.subscription_price AS subscription_price2
, t2.customer_gender AS customer_gender2
, t2.age_group AS age_group2
, t2.customer_country AS customer_country2
, t2.referral_type AS referral_type2

, t3.transaction_type AS transaction_type3
, t3.subscription_type AS subscription_type3
, t3.subscription_price AS subscription_price3
, t3.customer_gender AS customer_gender3
, t3.age_group AS age_group3
, t3.customer_country AS customer_country3
, t3.referral_type AS referral_type3

, t4.transaction_type AS transaction_type4
, t4.subscription_type AS subscription_type4
, t4.subscription_price AS subscription_price4
, t4.customer_gender AS customer_gender4
, t4.age_group AS age_group4
, t4.customer_country AS customer_country4
, t4.referral_type AS referral_type4

, MIN(t1.transaction_date) AS transaction_date1
, MIN(t2.transaction_date) AS transaction_date2
, MIN(t3.transaction_date) AS transaction_date3
, MIN(t4.transaction_date) AS transaction_date4
FROM specific_tx AS t1
JOIN specific_tx AS t2
ON t1.cust_id = t2.cust_id
AND t2.tx_num = t1.tx_num + 1 
LEFT JOIN specific_tx AS t3
ON t1.cust_id = t3.cust_id
AND t3.tx_num = t1.tx_num + 2 
LEFT JOIN specific_tx AS t4
ON t1.cust_id = t4.cust_id
AND t4.tx_num = t1.tx_num + 3 
-- WHERE t4.transaction_date IS NOT NULL
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29
ORDER BY 1, transaction_date1
--  ) test
-- WHERE cust_id IN

-- (SELECT cust_id
-- FROM specific_tx
-- WHERE tx_num = 4
-- )

