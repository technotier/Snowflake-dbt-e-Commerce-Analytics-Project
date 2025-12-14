-- create product dashboard view
create or replace view analytics_schema.product_performance_view as 
with 
products_metrics_cte as (
select
dp.product_id,
dp.product_name,
dp.category_name,
dp.price_segment,
dp.stock_quantity,
dp.stock_status,
dp.profit_percent,
dp.margin_category,
dp.sale_price,
dp.cost_price,
count(distinct fs.order_id) as order_counts,
sum(fs.net_amount) as total_revenue,
sum(fs.quantity * dp.cost_price) as total_cost,
sum(fs.net_profit_amount) as total_profit,
sum(fs.quantity) as total_unit_sold,
round(total_unit_sold * 100.0 / nullif(total_unit_sold + stock_quantity, 0), 2) as stock_turn_over,
min(fs.order_date) as first_sale_date,
max(fs.order_date) as last_sale_date,
count(distinct fs.order_date) as active_days,
round(order_counts * 1.0 / nullif(active_days, 0), 2) as daily_order_rate,
datediff('day', last_sale_date, current_date()) as since_last_order,
count(distinct fs.customer_id) as unique_customers,
sum(fs.discounts) as total_discount_given,
count(distinct case when fs.discount_flag = 'Discounted' then fs.order_id end) as discounted_sales
from 
analytics_schema.fact_sales fs left join analytics_schema.dim_products dp
on fs.product_id = dp.product_id
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
),
product_rank_cte as (
select
*,
dense_rank() over(order by total_revenue desc) as revenue_rank,
dense_rank() over(order by total_profit desc) as profit_rank,
dense_rank() over(order by total_unit_sold desc) as volume_rank,
dense_rank() over(order by profit_percent desc) as profit_margin_rank,
percent_rank() over(order by total_revenue) as revenue_percentile,
percent_rank() over(order by total_unit_sold) as volume_percentile,
case 
    when revenue_percentile >= 0.8 then 'A - Top 20%'
    when revenue_percentile >= 0.5 then 'B - Middle 30%'
    when revenue_percentile >= 0.2 then 'C - Next 30%'
    else 'D - Bottom 20%'
end as revenue_category,
case 
    when volume_percentile >= 0.8 then 'High Volume'
    when volume_percentile >= 0.5 then 'Medium Volume'
    when volume_percentile >= 0.2 then 'Low Volume'
    else 'Very Low Volume'
end as volume_category,
case 
    when active_days >= 50 then 'Year Round Product'
    when active_days >= 25 then 'Seasonal Product'
    else 'Occasional Product'
end as product_seasonality,
case 
    when unique_customers >= 40 then 'High Engagement'
    when unique_customers >= 20 then 'Medium Engagament'
    when unique_customers >= 5 then 'Low Engagement'
    else 'Limited Appeal'
end as customer_engagement,
case
    when stock_status = 'Out of Stock' then '🛑 Urgent Restock'
    when stock_status = 'Low' and daily_order_rate > 1 then 'Monitor Closely'
    when stock_turn_over > 80 then 'Fast Moving'
    when stock_turn_over < 20 then 'Slow Moving'
    else 'Normal Movement'
end as inventory_status
from
products_metrics_cte
)
select
*,
case 
    when revenue_category = 'A - Top 20%' and margin_category in ('Very High', 'High Margin') 
        then '🏆 Star Product'
    when revenue_category = 'A - Top 20%' then '⭐ Revenue Driver'
    when margin_category in ('Very High', 'High Margin') and volume_category = 'High Volume' 
        then '💰 Profit Champion'
    when stock_status = 'Out of Stock' and revenue_category in ('A - Top 20%', 'B - Middle 30%')
        then '⚠️ High Priority Restock'
    else '📊 Regular Product'
end as product_status
from
product_rank_cte;




