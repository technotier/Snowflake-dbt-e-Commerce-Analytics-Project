{{
    config(
        materialized='table'
    )
}}

with 
order_dates_cte AS (
    SELECT DISTINCT order_date
    FROM {{ source('raw_schema', 'orders') }}
),
date_range_cte AS (
    SELECT 
        MIN(order_date) as start_date,
        MAX(order_date) as end_date
    FROM order_dates_cte
),
all_dates_cte AS (
    SELECT 
        DATEADD('day', SEQ4(), (SELECT start_date FROM date_range_cte)) as full_date
    FROM TABLE(GENERATOR(ROWCOUNT => 10000))
    WHERE full_date <= (SELECT end_date FROM date_range_cte)
),
final_cte AS (
    SELECT
        full_date as order_date,
        YEAR(full_date) as year,
        MONTH(full_date) as month_num,
        MONTHNAME(full_date) as month,
        QUARTER(full_date) as quarter_num,
        'Q' || QUARTER(full_date) as quarter,
        DAYOFWEEK(full_date) as day_of_week,
        CASE 
            WHEN DAYOFWEEK(full_date) = 1 THEN 'Monday'
            WHEN DAYOFWEEK(full_date) = 2 THEN 'Tuesday'
            WHEN DAYOFWEEK(full_date) = 3 THEN 'Wednesday'
            WHEN DAYOFWEEK(full_date) = 4 THEN 'Thursday'
            WHEN DAYOFWEEK(full_date) = 5 THEN 'Friday'
            WHEN DAYOFWEEK(full_date) = 6 THEN 'Saturday'
            WHEN DAYOFWEEK(full_date) = 7 THEN 'Sunday'
        END as week_name,
        CASE 
            WHEN MONTH(full_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(full_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(full_date) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Fall'
        END as season,
        CASE 
            WHEN DAYOFWEEK(full_date) IN (6, 7) THEN 'Weekend'
            ELSE 'Weekday'
        END as day_category,
        CASE 
            WHEN MONTH(full_date) = 1 AND DAY(full_date) = 1 THEN 'New Year'
            WHEN MONTH(full_date) = 12 AND DAY(full_date) = 25 THEN 'Christmas'
            ELSE NULL 
        END as holiday_name
    FROM all_dates_cte
)
SELECT * FROM final_cte
ORDER BY order_date