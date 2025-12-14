{{
    config(
        materialized='table'
    )
}}

select
id::integer as order_item_id,
order_id::integer as order_id,
product_id::integer as product_id,
quantity::integer as quantity,
unit_price::decimal(10, 2) as unit_price,
discounts::decimal(10, 2) as discounts,
current_timestamp() as loaded_at
from
{{ ref('stg_order_items') }}
where id is not null 
and order_id is not null 
and product_id is not null 