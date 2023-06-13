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

--THEN JOIN tables ACCORDING to join strategy
