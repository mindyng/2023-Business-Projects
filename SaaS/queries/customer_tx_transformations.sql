--Taking out 5th transaction since seems like extraneous CHURN event

WITH transaction_num AS (
SELECT *
, ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY transaction_date) AS tx_num
FROM public.saas_cust_transactions
ORDER BY cust_id, transaction_date
)

SELECT *
FROM transaction_num
WHERE tx_num <5
