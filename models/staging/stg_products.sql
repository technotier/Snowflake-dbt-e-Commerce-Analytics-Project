{{
    config(
        materialiazed='view'
    )
}}

select
id,
category_id,
product_name,
sale_price,
cost_price,
stock_quantity,
current_timestamp() as loaded_at
from
{{ source('raw_schema', 'products') }}
