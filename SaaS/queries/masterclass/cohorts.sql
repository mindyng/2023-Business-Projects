-- those who purchased gordon ramsay class
-- those who purchased gordon ramsay class along with other class(es)
-- either of those groups buying for personal use/gift to other

WITH dedup_page_views AS ( 
SELECT *
, ROW_NUMBER() OVER (PARTITION BY anonymous_id, received_at, class, channel_grouping, traffic_source, ad_type, acquisition_type, user_agent ORDER BY received_at) AS dup_count
FROM masterclass.pages
)

, clean_page_views AS (
SELECT anonymous_id
, received_at
, class
, channel_grouping
, traffic_source
, ad_type
, acquisition_type
, user_agent
FROM dedup_page_views
WHERE dup_count = 1
)

, dedup_homepage_click AS (
SELECT *
, ROW_NUMBER() OVER (PARTITION BY anonymous_id, received_at, action, class, location ORDER BY received_at) AS dup_count
FROM masterclass.homepage
)

, clean_homepage_click AS (
SELECT anonymous_id
,  received_at
, action
, class
, location 
FROM dedup_homepage_click
WHERE dup_count = 1
)

, dedup_marketing_click AS (
SELECT *
, ROW_NUMBER() OVER (PARTITION BY anonymous_id, received_at, class, location, action, video, video_carousel_number ORDER BY received_at) AS dup_count
FROM masterclass.marketing
)

, clean_marketing_click AS (
SELECT anonymous_id
, received_at
, class
, location
, action
, video
, video_carousel_number
FROM dedup_marketing_click
WHERE dup_count = 1
)

, dedup_purchase_click AS (
SELECT *
, ROW_NUMBER() OVER (PARTITION BY anonymous_id, received_at, class, location, action ORDER BY received_at) AS dup_count
FROM masterclass.purchase_click
)

, clean_purchase_click AS (
SELECT anonymous_id
, received_at
, class
, location
, action
FROM dedup_purchase_click
WHERE dup_count = 1
)

, dedup_purchases AS ( --distinct at anonymous_id, received_at, product_id; should be joining on this
SELECT *
, ROW_NUMBER() OVER (PARTITION BY anonymous_id, received_at, product_id ORDER BY received_at) AS dup_count
FROM masterclass.purchased_class
)

--join strategy:
--take a customer who purchased 1 product and another who purchased >1 product and QA stitching tables
--go backwards to stitch relevant views, clicks, purchase clicks and finally purchased item

, sample_page_views AS (
SELECT anonymous_id
, MAX(received_at) AS received_at
, class
, channel_grouping
, traffic_source
, ad_type
, acquisition_type
, user_agent
FROM clean_page_views
WHERE class IS NOT NULL
AND anonymous_id = '6555280d-165a-401e-8bbe-b57c661a704d'
GROUP BY 1, 3, 4, 5, 6, 7, 8
)

, sample_homepage_click AS(
SELECT anonymous_id
, MAX(received_at) AS received_at
, action
, class
, location
FROM clean_homepage_click
WHERE anonymous_id = '6555280d-165a-401e-8bbe-b57c661a704d'
GROUP BY 1, 3, 4, 5
)

, sample_marketing_click AS (
SELECT anonymous_id
, MAX(received_at) AS received_at
, class
, location
, action
, video
, video_carousel_number
FROM clean_marketing_click
WHERE anonymous_id = '6555280d-165a-401e-8bbe-b57c661a704d'
GROUP BY 1, 3, 4, 5, 6, 7
)

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
SELECT anonymous_id
, MAX(received_at) AS received_at --last attribution
, product_id
, total
, revenue
, discount
, MAX(is_gift) AS is_gift --get true if gifted
FROM dedup_purchases
WHERE anonymous_id = '6555280d-165a-401e-8bbe-b57c661a704d'
GROUP BY 1, 3, 4, 5, 6
)

-- SELECT pv.anonymous_id
-- , pv.received_at AS page_view_time
-- , pv.channel_grouping
-- , pv.traffic_source
-- , pv.ad_type
-- , pv.acquisition_type
-- , pv.user_agent
-- , hc.received_at AS homepage_click_time
-- , hc.location AS homepage_click_location
-- , mc.received_at AS marketing_click_time
-- , COALESCE(pv.class, hc.action, mc.class, pc.class, product_id) AS class
-- , mc.location AS marketing_click_location
-- , mc.action AS marketing_click_event
-- , video AS marketing_click_video
-- , video_carousel_number
-- , pc.received_at AS purchase_click_time
-- , pc.location AS purchase_click_location
-- , pc.action AS purchase_click_event
-- , p.received_at AS purchase_time
-- , p.total
-- , p.revenue
-- , p.discount
-- , p.is_gift
-- FROM sample_page_views AS pv
-- FULL JOIN sample_homepage_click AS hc
-- ON pv.anonymous_id = hc.anonymous_id
-- AND pv.received_at <= hc.received_at
-- RIGHT JOIN sample_purchase_click AS pc
-- ON hc.anonymous_id = pc.anonymous_id
-- AND hc.action = pc.class
-- AND hc.received_at < pc.received_at
-- FULL JOIN sample_marketing_click AS mc
-- ON mc.anonymous_id = pc.anonymous_id
-- AND mc.class = pc.class
-- AND mc.received_at < pc.received_at
-- FULL JOIN sample_purchase AS p
-- ON pc.anonymous_id = p.anonymous_id
-- AND pc.class = p.product_id
-- AND pc.received_at <= p.received_at

-- SELECT hc.anonymous_id
-- , hc.received_at AS homepage_click_time
-- , hc.location AS homepage_click_location
-- , mc.received_at AS marketing_click_time
-- , COALESCE(hc.action, mc.class, pc.class, product_id) AS class
-- , mc.location AS marketing_click_location
-- , mc.action AS marketing_click_event
-- , video AS marketing_click_video
-- , video_carousel_number
-- , pc.received_at AS purchase_click_time
-- , pc.location AS purchase_click_location
-- , pc.action AS purchase_click_event
-- , p.received_at AS purchase_time
-- , p.total
-- , p.revenue
-- , p.discount
-- , p.is_gift

-- FROM sample_homepage_click AS hc
-- FULL JOIN sample_purchase_click AS pc --keep all rows from purchase click and matching homepage click
-- ON hc.anonymous_id = pc.anonymous_id
-- AND hc.action = pc.class
-- AND hc.received_at <= pc.received_at
-- FULL JOIN sample_marketing_click AS mc --keep all rows from purchase click and matching marketing clicks
-- ON mc.anonymous_id = pc.anonymous_id
-- AND mc.class = pc.class
-- AND mc.received_at <= pc.received_at
-- FULL JOIN sample_purchase AS p --keep all rows from purchase click and purchases, 
-- ON pc.anonymous_id = p.anonymous_id
-- AND pc.class = p.product_id
-- AND pc.received_at <= p.received_at

-- , test AS (SELECT anonymous_id
-- , MAX(received_at) OVER (PARTITION BY anonymous_id, class) AS purchase_click_last_touch
-- , class
-- , location
-- , action
-- FROM clean_purchase_click
-- --WHERE anonymous_id = '6555280d-165a-401e-8bbe-b57c661a704d'
-- GROUP BY 1, 3, 4, 5
-- )

-- , test_count  AS (SELECT *
-- , COUNT(anonymous_id) OVER (PARTITION BY anonymous_id, class) AS cust_purchase_count
-- FROM test
-- )

-- SELECT *
-- FROM test_count
-- WHERE cust_purchase_count = 4			

, gordon_ramsay_purchases AS (
SELECT *
FROM masterclass.purchased_class
WHERE product_id LIKE '%gordon-ramsay%'
)

, mixed_purchases AS (
SELECT *
	, SUM(CASE WHEN dist_cust_prod = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY anonymous_id) AS total_dist_cust_purchases
FROM (SELECT *
, ROW_NUMBER() OVER (PARTITION BY anonymous_id, product_id) AS dist_cust_prod
FROM masterclass.purchased_class
WHERE anonymous_id IN (SELECT DISTINCT anonymous_id FROM gordon_ramsay_purchases)) AS sub
)

SELECT COUNT(DISTINCT anonymous_id)
--, ROW_NUMBER() OVER (PARTITION BY anonymous_id, product_id ORDER BY received_at) AS dup
FROM mixed_purchases
WHERE total_dist_cust_purchases > 1 --when anonymous_id made GR class with another MC product (other class/annual pass)
-- AND is_gift = 't'
