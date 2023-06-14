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
-- , total
-- , revenue
-- , discount
-- , is_gift
-- FROM sample_homepage_click AS hc
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

-- SELECT * 
-- FROM sample_marketing_click AS mc
-- FULL JOIN sample_purchase_click AS pc
-- ON mc.anonymous_id = pc.anonymous_id
-- AND mc.class = pc.class
-- AND mc.received_at <= pc.received_at
-- FULL JOIN sample_purchase AS p
-- ON pc.anonymous_id = p.anonymous_id
-- AND pc.class = p.product_id
-- AND pc.received_at <= p.received_at
