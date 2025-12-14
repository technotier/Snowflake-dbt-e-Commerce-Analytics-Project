{{
    config(
        materialized='view'
    )
}}

select
id,
first_name,
last_name,
email,
phone,
city,
country,
gender,
signup_date,
current_timestamp() as loaded_at
from
{{ source('raw_schema', 'customers') }}