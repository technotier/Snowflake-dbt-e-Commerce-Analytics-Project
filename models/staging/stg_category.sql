{{
    config(
        materialized='view'
    )
}}

select
id,
category_name,
current_timestamp() as loaded_at
from
{{ source('raw_schema', 'category') }}
