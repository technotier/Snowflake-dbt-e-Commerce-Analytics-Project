{{
    config(
        materialized='table'
    )
}}

select
id::integer as customer_id,
initcap(trim(concat(first_name, ' ', last_name))) as customer_name,
lower(trim(email)) as email,
trim(phone) as phone,
upper(trim(city)) as city,
upper(trim(country)) as country,
case 
    when lower(trim(gender)) = 'male' then 'M'
    when lower(trim(gender)) = 'female' then 'F'
end as gender,
signup_date::date as signup_date,
datediff('day', signup_date, current_date()) as days_as_customer,
current_timestamp() as loaded_at
from
{{ ref('stg_customers') }}
where id is not null