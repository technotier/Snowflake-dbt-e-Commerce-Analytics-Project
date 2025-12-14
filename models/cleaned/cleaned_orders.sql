{{
    config(
        materialized='table'
    )
}}

select
id::integer as order_id,
customer_id::integer as customer_id,
order_date::date as order_date,
lower(trim(order_status)) as order_status,
current_timestamp() as loaded_at
from
{{ ref('stg_orders') }}
where id is not null
and customer_id is not null