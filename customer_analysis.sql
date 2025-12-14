-- yearly value projection based on present spending of customers
SELECT 
value_tier,
activity_status,
COUNT(*) as customer_count,
ROUND(AVG(days_as_customer), 2) as avg_customer_age,
ROUND(AVG(total_spent / NULLIF(days_as_customer, 0) * 365), 2) as projected_annual_value,
ROUND(AVG(total_spent), 2) as current_total_value
FROM analytics_schema.customers_analytics_view 
WHERE days_as_customer > 30
GROUP BY value_tier, activity_status
ORDER BY projected_annual_value DESC;

-- check up-sale or cross sale based on aov
SELECT 
    CASE 
        WHEN aov > 1000 THEN 'High AOV (>1000)'
        WHEN aov > 500 THEN 'Medium AOV (500-1000)'
        WHEN aov > 200 THEN 'Low AOV (200-500)'
        ELSE 'Very Low AOV (<200)'
    END as aov_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(total_orders), 2) as avg_orders,
    ROUND(AVG(total_spent), 2) as avg_lifetime_value,
    ROUND(AVG(discount_sensitivity), 2) as avg_discount_usage
FROM analytics_schema.customers_analytics_view 
WHERE total_orders > 0
GROUP BY 1
ORDER BY avg_lifetime_value DESC;

-- rfm segment analysis for annual budget planing
SELECT
rfm_segment,
COUNT(*) as segment_size,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM analytics_schema.customers_analytics_view), 2) as percentage,
ROUND(AVG(total_spent), 2) as avg_customer_value,
ROUND(SUM(total_spent), 2) as segment_total_value,
ROUND(AVG(recency_days), 2) as avg_recency
FROM analytics_schema.customers_analytics_view 
GROUP BY rfm_segment
ORDER BY segment_total_value DESC;

-- discount impact based on value tier and their aov
SELECT
value_tier,
COUNT(*) as customer_count,
ROUND(AVG(discount_sensitivity), 2) as avg_discount_usage,
ROUND(AVG(total_spent), 2) as avg_spending,
ROUND(AVG(aov), 2) as avg_aov
FROM analytics_schema.customers_analytics_view 
WHERE total_orders > 0
GROUP BY value_tier
ORDER BY avg_discount_usage DESC;

-- high retention customers profiles
SELECT
customer_name,
days_as_customer,
total_orders,
retention_level,
purchase_pattern,
unique_product_purchase
FROM analytics_schema.customers_analytics_view 
WHERE retention_level = 'High Retention'
AND purchase_pattern = 'Frequent Buyer'
ORDER BY days_as_customer DESC;

-- Male vs Female customers analysis
SELECT
gender,
COUNT(*) as customer_count,
ROUND(AVG(total_spent), 2) as avg_lifetime_value,
ROUND(AVG(aov), 2) as avg_order_value,
ROUND(AVG(total_orders), 2) as avg_orders,
ROUND(AVG(recency_days), 2) as avg_recency
FROM analytics_schema.customers_analytics_view 
GROUP BY gender
ORDER BY avg_lifetime_value DESC;

-- VIP or Premium customers who inactive over 180+ days
SELECT
customer_name,
last_order,
recency_days,
total_spent,
value_tier,
recommended_actions
FROM analytics_schema.customers_analytics_view 
WHERE activity_status = 'Dormant' 
AND value_tier IN ('VIP', 'Premium')
ORDER BY total_spent DESC;

-- top customers for special promotion offer or discounts
SELECT
customer_name,
total_spent,
total_orders,
rfm_segment,
customer_status,
recommended_actions,
last_order
FROM analytics_schema.customers_analytics_view 
WHERE customer_status = '✅ Active Buyer'
ORDER BY total_spent DESC
LIMIT 10;

-- customers list for win back campaigns
SELECT
customer_name,
recency_days,
total_orders,
total_spent, 
activity_status,
rfm_segment,
recommended_actions
FROM analytics_schema.customers_analytics_view 
WHERE rfm_segment = 'At Risk' 
AND total_spent > 500
ORDER BY total_spent DESC;
