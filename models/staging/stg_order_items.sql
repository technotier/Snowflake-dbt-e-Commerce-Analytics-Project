{{
    config(
        materialized='view'
    )
}}

select
id,
order_id,
product_id,
quantity,
unit_price,
discounts,
current_timestamp() as loaded_at
from
{{ source('raw_schema', 'order_items') }}