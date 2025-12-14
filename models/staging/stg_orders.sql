{{
    config(
        materialized='view'
    )
}}

select
id,
customer_id,
order_date,
order_status,
current_timestamp() as loaded_at
from
{{ source('raw_schema', 'orders') }}