--Defining an "adopted user" as a user who has logged into the product on 
--three separate days in at least one seven-day period, 
--identify which factors predict future user adoption.

--get the users who are adopted based on above definition and have users left joined to this
WITH touches AS (SELECT user_id
, time_stamp
, EXTRACT(WEEK FROM time_stamp) AS ts_wk
, COUNT(time_stamp) OVER (PARTITION BY user_id, EXTRACT(WEEK FROM time_stamp)) AS eng_per_week_per_user
FROM public.asana_user_engagement
-- ORDER BY user_id
-- , ts_wk
-- , time_stamp
)

, adopted AS (
SELECT DISTINCT user_id
FROM touches
WHERE eng_per_week_per_user >= 3
)

SELECT *
FROM public.asana_users
LEFT JOIN adopted
ON asana_users.object_id = adopted.user_id
WHERE adopted.user_id IS NOT NULL
