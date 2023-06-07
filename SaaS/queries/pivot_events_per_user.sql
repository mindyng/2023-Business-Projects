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
, t1.transaction_type
, t1.subscription_type
, t1.subscription_price
, t1.customer_gender
, t1.age_group
, t1.customer_country
, t1.referral_type

, t2.transaction_type
, t2.subscription_type
, t2.subscription_price
, t2.customer_gender
, t2.age_group
, t2.customer_country
, t2.referral_type

-- , t3.transaction_type
-- , t3.subscription_type
-- , t3.subscription_price
-- , t3.customer_gender
-- , t3.age_group
-- , t3.customer_country
-- , t3.referral_type

-- , t4.transaction_type
-- , t4.subscription_type
-- , t4.subscription_price
-- , t4.customer_gender
-- , t4.age_group
-- , t4.customer_country
-- , t4.referral_type

, MIN(t1.transaction_date) AS transaction_date_1
, MIN(t2.transaction_date) AS transaction_date_2
, MIN(t3.transaction_date) AS transaction_date_3
, MIN(t4.transaction_date) AS transaction_date_4
FROM specific_tx AS t1
LEFT JOIN specific_tx AS t2
ON t1.cust_id = t2.cust_id
AND t2.tx_num = t1.tx_num + 1 
LEFT JOIN specific_tx AS t3
ON t1.cust_id = t3.cust_id
AND t3.tx_num = t1.tx_num + 2 
LEFT JOIN specific_tx AS t4
ON t1.cust_id = t4.cust_id
AND t4.tx_num = t1.tx_num + 3 
-- WHERE t4.transaction_date IS NOT NULL
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
ORDER BY 1, transaction_date_1
--  ) test
-- WHERE cust_id IN

-- (SELECT cust_id
-- FROM specific_tx
-- WHERE tx_num = 4
-- )
