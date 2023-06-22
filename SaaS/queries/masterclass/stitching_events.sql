--join strategy:
--take a customer who purchased 1 product and another who purchased >1 product and QA stitching tables
--go backwards to stitch relevant views, clicks, purchase clicks and finally purchased item

WITH dedup_page_views AS ( 
SELECT *
, ROW_NUMBER() OVER (PARTITION BY anonymous_id, received_at, class, channel_grouping, traffic_source, ad_type, acquisition_type, user_agent ORDER BY received_at) AS dup_count
FROM masterclass.pages
)

, clean_page_views AS (
SELECT anonymous_id
, received_at
, name
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
, CASE WHEN action = 'gift' THEN 't' ELSE 'f' END AS is_gift
, ROW_NUMBER() OVER (PARTITION BY anonymous_id, received_at, class, location, action ORDER BY received_at) AS dup_count
FROM masterclass.purchase_click
)

, clean_purchase_click AS (
SELECT anonymous_id
, received_at
, class
, location
, is_gift
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
AND anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8'
GROUP BY 1, 3, 4, 5, 6, 7, 8
)

, sample_homepage_click AS(
SELECT anonymous_id
, MAX(received_at) AS received_at
, action
, class
, location
FROM clean_homepage_click
WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8'
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
WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8'
GROUP BY 1, 3, 4, 5, 6, 7
)

, sample_purchase_click AS (
SELECT anonymous_id
, MAX(received_at) AS received_at
, class
, location
, MAX(is_gift) --choose gift if it exists
FROM clean_purchase_click
WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8'
GROUP BY 1, 3, 4
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
WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8'
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
-- --WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8'
-- GROUP BY 1, 3, 4, 5
-- )

-- SELECT pv.anonymous_id
-- , pv.received_at AS page_view_time
-- , pv.name AS page_type
-- , pv.channel_grouping
-- , pv.traffic_source
-- , pv.ad_type
-- , pv.acquisition_type
-- , pv.user_agent
-- , hc.received_at AS homepage_click_time
-- , hc.action AS hompeage_action
-- , hc.location AS homepage_location
-- , mc.received_at AS marketing_page_click_time
-- , mc.location AS marketing_page_location
-- , mc.action AS marketing_action
-- , mc.video 
-- , mc.video_carousel_number
-- , pc.received_at AS purchase_click_time
-- , COALESCE (pv.class, hc.class, mc.class, pc.class, purch.product_id) AS product
-- , pc.location
-- , purch.received_at AS purchase_time
-- , purch.total
-- , purch.discount
-- , purch.is_gift
-- FROM (SELECT * FROM clean_page_views WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8') AS pv
-- FULL JOIN (SELECT * FROM clean_homepage_click WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8') AS hc
-- ON pv.anonymous_id = hc.anonymous_id
-- AND pv.class = hc.class
-- AND hc.received_at >= pv.received_at

-- FULL JOIN (SELECT * FROM clean_marketing_click WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8') AS mc
-- ON pv.anonymous_id = mc.anonymous_id
-- AND pv.class = mc.class
-- AND mc.received_at >= pv.received_at

-- FULL JOIN (SELECT * FROM clean_purchase_click WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8') AS pc
-- ON pv.anonymous_id = pc.anonymous_id
-- AND pv.class = pc.class
-- AND pc.received_at >= pv.received_at

-- FULL JOIN (SELECT * FROM masterclass.purchased_class WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8') AS purch
-- ON pc.anonymous_id = purch.anonymous_id
-- AND pc.class = purch.product_id
-- AND pc.is_gift = purch.is_gift
-- AND pc.received_at <= purch.received_at

--SELECT name, COUNT(*) FROM clean_page_views GROUP BY 1 ORDER BY 2 DESC --WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8'
-- SELECT * FROM clean_homepage_click WHERE anonymous_id = 'ba4370b9-b246-47de-9ca2-9c9b3b3c60f8'
