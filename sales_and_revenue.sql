-- discount impact analysis 
with 
monthly_discounts_cte as (
select 
dd.month_num as month_num,
dd.month as month,
count(distinct fs.order_id) as total_orders,
count(distinct case when fs.discount_flag = 'Discounted' then fs.order_id end) as discounted_orders,
sum(fs.net_amount) as total_revenue,
sum(fs.discounts) as total_discounts,
from 
analytics_schema.fact_sales fs join analytics_schema.dim_date dd on 
fs.order_date = dd.order_date
where fs.order_status = 'completed'
group by 1, 2
),
final_cte as (
select 
month,
month_num,
total_orders,
discounted_orders,
total_revenue,
total_discounts,
total_discounts * 100.0 / nullif(total_revenue, 0) as discount_percent_of_revenue
from 
monthly_discounts_cte
)
select 
month,
total_orders,
discounted_orders,
total_revenue,
total_discounts,
discount_percent_of_revenue,
case 
	when discount_percent_of_revenue > 10 then '🔴 High Impact'
	else '🟢 Low Impact'
end as discount_impact
from 
final_cte
order by month_num;

-- mom growth rate analysis 
with 
monthly_revenue_cte as (
select
dd.month_num as month_num,
dd.month as month,
count(distinct fs.order_id) as total_orders,
sum(fs.net_amount) as monthly_revenue
from
analytics_schema.fact_sales fs join analytics_schema.dim_date dd on 
fs.order_date = dd.order_date
where fs.order_status = 'completed'
group by 1, 2
),
prev_month_cte as (
select
month_num,
month,
total_orders,
monthly_revenue,
coalesce(lag(monthly_revenue) over(order by month_num), 0) as prev_month_revenue
from 
monthly_revenue_cte
),
sales_diff_cte as (
select 
month,
total_orders,
monthly_revenue,
prev_month_revenue,
monthly_revenue - prev_month_revenue as sales_change
from 
prev_month_cte
),
mom_cte as (
select 
month,
total_orders,
monthly_revenue,
prev_month_revenue,
sales_change * 100.0 / nullif(monthly_revenue, 0) as mom_growth_rate
from 
sales_diff_cte
)
select 
month,
total_orders,
monthly_revenue,
prev_month_revenue,
mom_growth_rate,
case 
    when mom_growth_rate > 15 then '🚀 Excellent Growth'
    when mom_growth_rate > 5 then '📈 Strong Growth'
    when mom_growth_rate > 0 then '👍 Positive Growth'
    when mom_growth_rate < 0 then '📉 Declining'
    else '➡️ Stable'
end as growth_rate_status,
from 
mom_cte;

-- montyhly profit analysis
WITH 
MONTHLY_PROFIT_CTE AS 
(
SELECT
DD.MONTH AS MONTH,
SUM(FS.NET_AMOUNT) AS TOTAL_REVENUE,
SUM(FS.NET_PROFIT_AMOUNT) AS TOTAL_PROFIT
FROM 
ANALYTICS_SCHEMA.FACT_SALES FS JOIN ANALYTICS_SCHEMA.DIM_DATE DD ON 
FS.ORDER_DATE = DD.ORDER_DATE
GROUP BY 1
),
PROFIT_PERCENT_CTE AS 
(
SELECT 
MONTH,
TOTAL_PROFIT,
TOTAL_PROFIT * 100.0 / NULLIF(TOTAL_REVENUE, 0) AS PROFIT_PERCENT 
FROM 
MONTHLY_PROFIT_CTE
)
SELECT
MONTH,
TOTAL_PROFIT,
PROFIT_PERCENT,
CASE 
WHEN PROFIT_PERCENT > 30 THEN '💰 EXCELLENT MARGIN'
WHEN PROFIT_PERCENT > 15 THEN '📈 STRONG MARGIN'
WHEN PROFIT_PERCENT > 0 THEN '👍 POSITIVE MARGIN'
WHEN PROFIT_PERCENT < 0 THEN '📉 DECLINE'
ELSE 'STABLE'
END AS MARGIN_CATEGORY
FROM 
PROFIT_PERCENT_CTE;

-- order analysis 
with 
order_counts_cte as (
select
dd.month_num as month_num,
dd.month as month,
count(distinct fs.order_id) as total_orders,
count(distinct case when fs.order_status = 'completed' then fs.order_id end) as successful_orders,
count(distinct case when fs.order_status = 'cancelled' then fs.order_id end) as cancelled_orders,
count(distinct case when fs.order_status = 'pending' then fs.order_id end) as pending_orders
from 
analytics_schema.fact_sales fs join analytics_schema.dim_date dd on 
fs.order_date = dd.order_date 
group by 1, 2
),
cancellation_rate_cte as (
select
month_num,
month,
total_orders,
successful_orders,
cancelled_orders,
pending_orders,
cancelled_orders * 100.0 / nullif(total_orders, 0) as cancellation_rate,
(successful_orders + pending_orders) * 100.0 / nullif(total_orders, 0) as fulfillent_rate
from 
order_counts_cte
)
select 
month,
total_orders,
cancelled_orders,
cancellation_rate,
fulfillent_rate,
case
    when cancellation_rate > 25 and fulfillent_rate < 60 THEN '🔴 Critical'
    when cancellation_rate > 20 and fulfillent_rate < 70 THEN '🟥 Very Poor'
    when cancellation_rate > 15 or fulfillent_rate < 75 THEN '🟠 Poor'
    when cancellation_rate > 5 and fulfillent_rate >= 75 THEN '🟡 Fair'
    when cancellation_rate <= 5 and fulfillent_rate >= 90 THEN '🟢 Excellent'
    else '🟢 Good'
end as order_performance
from cancellation_rate_cte
order by month_num;

-- order size analysis 
with 
order_size_cte as (
select 
dd.month,
dd.month_num,
sum(fs.net_amount) as total_revenue,
sum(fs.net_profit_amount) as total_profit,
fs.order_size
from 
analytics_schema.fact_sales fs join analytics_schema.dim_date dd on 
fs.order_date = dd.order_date
group by 1, 2, 5
order by 2
)
select 
month,
total_revenue,
total_profit,
order_size,
case 
	when order_size = 'Bulk Order' then '✅ Execellent'
	else 'Fair'
end as order_size_analysis
from 
order_size_cte

-- seasonal sales analysis
with 
seasonal_sales_cte as (
select 
dd.season,
count(distinct fs.order_id) as total_orders,
sum(fs.net_amount) as total_revenue,
sum(fs.net_profit_amount) as total_profit
from 
analytics_schema.fact_sales fs join analytics_schema.dim_date dd on 
fs.order_date = dd.order_date 
group by 1
)
select
season,
total_orders,
total_revenue,
total_profit,
case 
	when total_profit > 100000 then '💰 Super Season'
	when total_profit > 90000 then '🎯 Execellent'
	when total_profit > 85000 then '📈 Strong'
	else '✅ Good'
end as seasonal_status
from 
seasonal_sales_cte;
