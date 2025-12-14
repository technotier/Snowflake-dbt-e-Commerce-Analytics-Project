{{
    config(
        materialized='table'
    )
}}

select
id::integer as category_id,
initcap(trim(category_name)) as category_name,
current_timestamp() as loaded_at
from
{{ ref('stg_category') }}
where id is not null
