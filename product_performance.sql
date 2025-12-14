-- high order rate products
SELECT
product_name,
active_days,
daily_order_rate,
total_revenue,
product_seasonality
FROM analytics_schema.product_performance_view 
WHERE daily_order_rate > (SELECT AVG(daily_order_rate) FROM analytics_schema.product_performance_view)
AND active_days < 30
ORDER BY total_revenue DESC
LIMIT 10;

-- high engagement products
SELECT
customer_engagement,
COUNT(*) as product_count,
AVG(total_revenue) as avg_revenue_per_product,
AVG(unique_customers) as avg_customers
FROM analytics_schema.product_performance_view 
GROUP BY customer_engagement
ORDER BY 
CASE customer_engagement
	WHEN 'High Engagement' THEN 1
	WHEN 'Medium Engagement' THEN 2
	WHEN 'Low Engagement' THEN 3
ELSE 4
END;

-- discount impact on category
SELECT
category_name, 
COUNT(*) as total_products,
SUM(discounted_sales) as total_discounted_sales,
ROUND(SUM(total_discount_given) * 100.0 / SUM(total_revenue), 2) as discount_to_revenue_ratio,
ROUND(AVG(profit_percent), 2) as avg_margin
FROM analytics_schema.product_performance_view 
WHERE discounted_sales > 0
GROUP BY category_name
ORDER BY total_discounted_sales DESC;

-- stock status for high demand product
SELECT
product_name,
category_name,
revenue_category, 
since_last_order,
daily_order_rate,
inventory_status
FROM analytics_schema.product_performance_view 
WHERE inventory_status = '🛑 Urgent Restock' 
AND revenue_category IN ('A - Top 20%', 'B - Middle 30%')
ORDER BY daily_order_rate DESC;

-- inventory management strategy
SELECT
revenue_category,
volume_category,
COUNT(*) as product_count,
SUM(stock_quantity) as total_inventory,
ROUND(AVG(stock_turn_over), 2) as avg_turnover,
ROUND(AVG(since_last_order), 1) as avg_days_since_last_order
FROM analytics_schema.product_performance_view 
GROUP BY revenue_category, volume_category
ORDER BY 
CASE revenue_category
	WHEN 'A - Top 20%' THEN 1
	WHEN 'B - Middle 30%' THEN 2
	WHEN 'C - Next 30%' THEN 3
	ELSE 4
END;

-- price segment wise products sales status
SELECT
price_segment,
COUNT(*) as product_count,
ROUND(AVG(total_revenue), 2) as avg_revenue,
ROUND(AVG(profit_percent), 2) as avg_margin,
ROUND(AVG(total_unit_sold), 0) as avg_units_sold
FROM analytics_schema.product_performance_view 
GROUP BY price_segment
ORDER BY avg_revenue DESC;

-- product with high order volume and margin
SELECT
product_name,
category_name,
total_unit_sold,
total_profit,
profit_percent,
volume_category
FROM analytics_schema.product_performance_view 
WHERE product_status = '💰 Profit Champion'
ORDER BY total_profit DESC;

-- Year-round vs Seasonal products for inventory stock planning
SELECT
product_seasonality,
COUNT(*) as product_count,
AVG(total_revenue) as avg_revenue,
SUM(total_revenue) as total_segment_revenue
FROM analytics_schema.product_performance_view 
GROUP BY product_seasonality
ORDER BY total_segment_revenue DESC;

-- low sale but high profit products for marketing or campaigns
SELECT product_name, category_name, stock_turn_over, 
       profit_percent, total_unit_sold, customer_engagement
FROM analytics_schema.product_performance_view 
WHERE stock_turn_over < 20 
AND margin_category IN ('Very High', 'High Margin')
ORDER BY profit_percent DESC;

-- top 20% revenue generated products
SELECT
product_name,
category_name,
total_revenue,
total_profit,
margin_category,
product_status,
daily_order_rate
FROM analytics_schema.product_performance_view 
WHERE product_status = '🏆 Star Product'
ORDER BY total_revenue DESC;

-- stock turn over
with 
product_sales_cte as (
select 
dp.product_id,
dp.product_name,
dp.stock_quantity,
count(distinct fs.order_id) as total_orders,
sum(fs.net_amount) as total_revenue,
sum(fs.net_profit_amount) as total_profit,
sum(fs.quantity) as total_unit_sold
from 
analytics_schema.fact_sales fs join analytics_schema.dim_products dp on 
fs.product_id = dp.product_id
group by 1, 2, 3
),
stock_turn_over_cte as (
select 
product_name,
stock_quantity,
total_orders,
total_revenue,
total_profit,
total_unit_sold,
round(total_unit_sold * 100.0 / nullif(total_unit_sold + stock_quantity, 0), 2) as stock_turn_over 
from 
product_sales_cte
)
select 
*,
case 
	when stock_turn_over > 80 then '🚨 Critical Stock - Immediate Reorder'
	when stock_turn_over > 60 then '⚠️ High Turnover - Monitor Closely'
	when stock_turn_over > 40 then '📊 Optimal Turnover - Healthy'
	when stock_turn_over > 20 then '📈 Moderate Turnover - Review Stock'
	when stock_turn_over > 0 then '📦 Slow Moving - Consider Promotion'
	else 'No Sales - Strategic decision needed'
end as stock_health
from 
stock_turn_over_cte
