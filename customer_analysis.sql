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

-- ইনসাইট: গ্রাহকের বর্তমান স্পেন্ডিং প্যাটার্ন থেকে বার্ষিক ভ্যালু প্রোজেকশন তৈরি করুন।

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

-- ইনসাইট: AOV সেগমেন্ট ভিত্তিক আপ-সেল/ক্রস-সেল অপারচুনিটিস চিহ্নিত করুন।

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

-- ইনসাইট: প্রতিটি RFM সেগমেন্টের আকার এবং তাদের মোট আর্থিক অবদান দেখে মার্কেটিং বাজেট বন্টন করুন।

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

-- ইনসাইট: কোন ভ্যালু টায়ারের গ্রাহকরা ডিসকাউন্টে বেশি সাড়া দেয় এবং তাদের AOV কত।

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

-- ইনসাইট: দীর্ঘদিনের হাই-রিটেনশন গ্রাহকদের প্রোফাইল বিশ্লেষণ করে অনুরূপ গ্রাহক আকর্ষণের স্ট্র্যাটেজি তৈরি করুন।

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

-- ইনসাইট: লিঙ্গভিত্তিক ক্রয় আচরণ বিশ্লেষণ করে টার্গেটেড মার্কেটিং ক্যাম্পেইন ডিজাইন করুন।

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

-- ইনসাইট: ১৮০+ দিন ক্রয় না করা ভিআইপি/প্রিমিয়াম গ্রাহকদের বিশেষ ডিসকাউন্ট বা সার্ভে পাঠিয়ে রিএক্টিভেট করুন।

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

-- ইনসাইট: আপনার ২০টি শীর্ষ গ্রাহক যারা সবচেয়ে বেশি খরচ করে এবং নিয়মিত ক্রয় করে। এদের বিশেষ সুযোগ-সুবিধা দিন।

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

-- ইনসাইট: ৫০০+ টাকা খরচ করেছে কিন্তু এখন ক্রয় কমিয়েছে এমন গ্রাহকদের উইন-ব্যাক ক্যাম্পেইনের জন্য প্রায়োরিটাইজ করুন।