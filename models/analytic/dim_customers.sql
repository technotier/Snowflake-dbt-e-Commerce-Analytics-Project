{{
    config(
        materialized='table'
    )
}}

select
    md5(customer_id || customer_name || email) as customer_sk,
    customer_id,
    customer_name,
    email,
    phone,
    city,
    country,
    gender,
    signup_date,
    days_as_customer,
    case 
    when days_as_customer >= 730 then 'Super Loyal'
    when days_as_customer >= 365 then 'Loyal'
    when days_as_customer >= 180 then 'Champion'
    when days_as_customer >= 90 then 'Regular'
    when days_as_customer >= 45 then 'New'
    else 'Very New'
    end as customer_segment,
    loaded_at,
    current_timestamp() as dim_loaded_at 
from {{ ref('cleaned_customers') }}
