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

SELECT user_id
, creation_time
, DATE(creation_time) AS creation_time_date
, EXTRACT(YEAR FROM creation_time) AS creation_time_year
, EXTRACT(MONTH FROM creation_time) AS creation_time_month
, EXTRACT(isodow FROM creation_time) AS creation_time_dow
, name
, email
, creation_source
, TO_TIMESTAMP(last_session_creation_time) AS last_session_creation_time
, EXTRACT(YEAR FROM TO_TIMESTAMP(last_session_creation_time)) AS last_session_creation_time_year
, EXTRACT(MONTH FROM TO_TIMESTAMP(last_session_creation_time)) AS last_session_creation_time_month
, EXTRACT(isodow FROM TO_TIMESTAMP(last_session_creation_time)) AS last_session_creation_time_dow
, opted_in_to_mailing_list
, enabled_for_marketing_drip
, org_id
, invited_by_user_id
, CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END AS adopted
FROM public.asana_users
LEFT JOIN adopted
ON asana_users.object_id = adopted.user_id
