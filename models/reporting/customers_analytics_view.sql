with
customers_metrics_cte as (
select
dc.customer_id as customer_id,
dc.customer_name,
dc.gender,
dc.days_as_customer,
min(fs.order_date) as first_order,
max(fs.order_date) as last_order,
datediff('day', first_order, last_order) as customer_active_days,
count(distinct fs.order_id) as total_orders,
sum(fs.net_amount) as total_spent,
round(total_spent / total_orders, 2) as aov,
sum(fs.discounts) as total_disconts_received,
count(distinct case when fs.discount_flag = 'Discounted' then fs.order_id end) as discounted_orders, 
count(distinct fs.product_id) as unique_product_purchase,
sum(fs.quantity) as total_items_purchase
from 
{{ ref('fact_sales') }} fs left join {{ ref('dim_customers')}} dc
on fs.customer_id = dc.customer_id
group by 1, 2, 3, 4
),
customer_rfm_cte as (
select
*,
datediff('day', last_order, current_date()) as recency_days,
total_orders as frequency,
total_spent as monetary,
ntile(5) over(order by recency_days desc) as recency_score,
ntile(5) over(order by total_orders) as frequency_score,
ntile(5) over(order by total_spent) as monetary_score
from 
customers_metrics_cte
),
rfm_segment_cte as (
select
*,
case 
    when recency_score >= 4 and frequency_score >= 4 and monetary_score >= 4 then 'Champion'
    when recency_score >= 3 and frequency_score >= 3 and monetary_score >= 3 then 'Loyal'
    when recency_score >= 3 and monetary_score >= 3 then 'Potential Loyalists'
    when recency_score >= 2 then 'Recent Customers'
    when frequency_score >= 3 then 'At Risk'
    else 'Lost Customers'
end as rfm_segment,
case 
    when total_spent > 5000 then 'VIP'
    when total_spent > 1000 then 'Premium'
    when total_spent > 500 then 'Regular'
    when total_spent > 100 then 'Basic'
    else 'New'
end as value_tier,
case 
    when recency_days <= 30 then 'Active'
    when recency_days <= 90 then 'Warming'
    when recency_days <= 180 then 'Cooling'
    else 'Dormant'
end as activity_status,
case 
    when total_orders >= 10 then 'Frequent Buyer'
    when total_orders >= 5 then 'Regular Buyer'
    when total_orders >= 2 then 'Occasional Buyer'
    else 'One-time Buyer'
end as purchase_pattern,
case 
    when days_as_customer > 365 and total_orders > 5 then 'High Retention'
    when days_as_customer > 180 and total_orders > 2 then 'Medium Retention'
    else 'Low Retention'
end as retention_level,
round(discounted_orders * 100.0 / nullif(total_orders, 0), 2) as discount_sensitivity,
case 
    when rfm_segment = 'Champions' and value_tier = 'VIP' then '🏆 Top Customer'
    when rfm_segment = 'Loyal Customers' and retention_level = 'High Retention' then '⭐ Valuable Customer'
    when activity_status = 'Active' and purchase_pattern = 'Frequent Buyer' then '✅ Active Buyer'
    when recency_days > 180 then '⚠️ Re-engagement Needed'
    else '📊 Regular Customer'
end as customer_status,
case 
    when rfm_segment = 'Champions' then 'Reward program, Exclusive offers'
    when rfm_segment = 'Loyal Customers' then 'Loyalty benefits, Early access'
    when rfm_segment = 'Potential Loyalists' then 'Personalized recommendations'
    when rfm_segment = 'At Risk' then 'Win-back campaign, Special discounts'
    when rfm_segment = 'Lost Customers' then 'Reactivation emails, Survey'
    else 'General marketing'
end as recommended_actions
from customer_rfm_cte
)
select * from rfm_segment_cte
