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

-- ইনসাইট: কম দিনে হাই অর্ডার রেটওয়ালা প্রোডাক্টগুলো সম্ভাব্য "ভাইরাল" বা হট ট্রেন্ডিং আইটেম।

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

-- ইনসাইট: হাই এনগেজমেন্ট প্রোডাক্টগুলো ক্রস-সেলিং এবং কাস্টমার রিটেনশন ক্যাম্পেইনের জন্য আদর্শ।

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

-- ইনসাইট: কোন ক্যাটাগরিতে ডিসকাউন্ট বেশি কার্যকরী হচ্ছে এবং তা মার্জিনে কতটা প্রভাব ফেলছে।

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

-- ইনসাইট: যেসব হাই-ডিমান্ড প্রোডাক্ট আউট অফ স্টক, সেগুলোতে তাত্ক্ষণিক রিস্টক প্রায়োরিটি দিন।

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

-- ইনসাইট: ABC অ্যানালাইসিস করে ইনভেন্টরি ম্যানেজমেন্ট স্ট্র্যাটেজি ডেভেলপ করুন:

SELECT
price_segment,
COUNT(*) as product_count,
ROUND(AVG(total_revenue), 2) as avg_revenue,
ROUND(AVG(profit_percent), 2) as avg_margin,
ROUND(AVG(total_unit_sold), 0) as avg_units_sold
FROM analytics_schema.product_performance_view 
GROUP BY price_segment
ORDER BY avg_revenue DESC;

-- ইনসাইট: কোন প্রাইস সেগমেন্ট (Premium, Mid-range, Economy) সবচেয়ে লাভজনক এবং ভলিউম জেনারেট করছে।

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

-- ইনসাইট: যে প্রোডাক্টগুলো ভালো ভলিউমের সাথে উচ্চ মার্জিন দিচ্ছে, তাদের প্রোডাকশন/স্টকিং বৃদ্ধি করুন।

SELECT
product_seasonality,
COUNT(*) as product_count,
AVG(total_revenue) as avg_revenue,
SUM(total_revenue) as total_segment_revenue
FROM analytics_schema.product_performance_view 
GROUP BY product_seasonality
ORDER BY total_segment_revenue DESC;

-- ইনসাইট: Year-round vs Seasonal প্রোডাক্টসের পারফরমেন্স তুলনা করে ইনভেন্টরি প্ল্যানিং অপটিমাইজ করুন।

SELECT product_name, category_name, stock_turn_over, 
       profit_percent, total_unit_sold, customer_engagement
FROM analytics_schema.product_performance_view 
WHERE stock_turn_over < 20 
AND margin_category IN ('Very High', 'High Margin')
ORDER BY profit_percent DESC;

-- ইনসাইট: কম বিক্রি কিন্তু উচ্চ মার্জিনের প্রোডাক্টগুলোকে টার্গেটেড মার্কেটিং বা বান্ডেল অফারের মাধ্যমে প্রমোট করুন।

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

-- ইনসাইট: টপ ২০% রেভেনিউ জেনারেটর যারা হাই মার্জিনও বজায় রাখছে। এগুলোকে মার্কেটিং ফোকাসে রাখুন।

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
