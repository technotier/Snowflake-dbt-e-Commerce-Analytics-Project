{{
    config(
        materialized='table'
    )
}}

select
id::integer as product_id,
category_id::integer as category_id,
initcap(trim(product_name)) as product_name,
sale_price::decimal(10, 2) as sale_price,
cost_price::decimal(10, 2) as cost_price,
stock_quantity::integer as stock_quantity,
current_timestamp() as loaded_at
from
{{ ref('stg_products') }}
where id is not null
and category_id is not null 