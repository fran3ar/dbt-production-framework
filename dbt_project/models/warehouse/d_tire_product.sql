with stg_products as (
    select * from {{ ref('stg_products') }}
)
select
    product_id,
    sku,
    brand,
    model_name,
    size_spec,
    product_category,
    cost_price,
    retail_price,
    round(cast(retail_price - cost_price as numeric), 2) as target_unit_margin
from stg_products
