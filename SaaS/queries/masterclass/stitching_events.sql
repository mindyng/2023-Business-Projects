--join strategy:
--take a customer who purchased 1 product and another who purchased >1 product and QA stitching tables
--go backwards to stitch relevant views, clicks, purchase clicks and finally purchased item

, sample_purchase_click AS (
SELECT anonymous_id
, MAX(received_at) AS received_at
, class
, location
, action
FROM clean_purchase_click
WHERE anonymous_id = '6555280d-165a-401e-8bbe-b57c661a704d'
GROUP BY 1, 3, 4, 5
)

, sample_purchase AS(
SELECT *
FROM dedup_purchases
WHERE anonymous_id = '6555280d-165a-401e-8bbe-b57c661a704d'
-- ORDER BY 1, 2
)

SELECT * 
FROM sample_purchase_click AS pc
LEFT JOIN sample_purchase AS p
ON pc.anonymous_id = p.anonymous_id
AND pc.class = p.product_id
AND pc.received_at <= p.received_at
