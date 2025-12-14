{{
    config(
        materialized='table'
    )
}}

select
md5(p.product_id || p.product_name || c.category_id || c.category_name) as product_sk,
p.product_id,
p.product_name,
c.category_id,
c.category_name,
p.sale_price,
p.cost_price,
p.sale_price - p.cost_price as profit_margin,
round((p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0), 2) as profit_percent,
p.stock_quantity,
case 
    when p.stock_quantity = 0 then 'Out of Stock'
    when p.stock_quantity < 10 then 'Very Low'
    when p.stock_quantity < 25 then 'Low'
    when p.stock_quantity < 50 then 'Medium'
    when p.stock_quantity < 100 then 'Moderate'
    else 'High Stock'
end as stock_status,
case 
    when p.sale_price >= 1000 then 'Luxury'
    when p.sale_price >= 800 then 'Premium'
    when p.sale_price >= 500 then 'High'
    when p.sale_price >= 250 then 'In Budget'
    when p.sale_price >= 100 then 'Economy'
    else 'Low Price'
end as price_segment,
case 
    when (p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0) > 75 then 'Very High'
    when (p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0) > 50 then 'High Margin'
    when (p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0) > 25 then 'Moderate'
    when (p.sale_price - p.cost_price) * 100.0 / nullif(p.sale_price, 0) > 10 then 'Medium'
    else 'Low Margin'
end as margin_category,
current_timestamp() as dim_products_loaded
from
{{ ref('cleaned_category') }} c join {{ ref('cleaned_products') }} p
on c.category_id = p.category_id
where p.product_id is not null 
and c.category_id is not null 
and p.sale_price >= 0
and p.cost_price >= 0
