{{
    config(
        materialized='table'
    )
}}


with
base_fact_cte as (
select
o.order_id,
o.customer_id,
o.order_date,
o.order_status,
oi.order_item_id,
oi.product_id,
oi.quantity,
oi.unit_price,
oi.discounts,
case 
    when oi.discounts > 0 then 'Discounted'
    else 'Full Price'
end as discount_flag,
oi.quantity * oi.unit_price as gross_amount,
(oi.quantity * oi.unit_price) - coalesce(oi.discounts, 0) as net_amount,
oi.quantity * dp.cost_price as total_cost
from
{{ ref('cleaned_orders') }} o
join {{ ref('cleaned_order_items') }} oi 
on o.order_id = oi.order_id
join {{ ref('dim_products') }} dp
on oi.product_id = dp.product_id
where o.order_id is not null 
and oi.order_item_id is not null
)
select
md5(
    coalesce(order_id::string, '') ||
    coalesce(order_item_id::string, '') ||
    coalesce(product_id::string, '') ||
    coalesce(customer_id::string, '') ||
    coalesce(order_date::string, '')
) as fact_sales_sk,
order_id,
customer_id,
order_date,
order_status,
order_item_id,
product_id,
quantity,
unit_price,
discounts,
discount_flag,
gross_amount,
net_amount,
total_cost,
net_amount - total_cost as net_profit_amount,
case 
    when quantity >= 10 then 'Bulk Order'
    when quantity >= 5 then 'Mid Size'
    when quantity >= 2 then 'Small Order'
    else 'Single Order'
end as order_size,
current_timestamp() as fact_sales_loaded
from
base_fact_cte