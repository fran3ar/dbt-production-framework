with source as (
    select * from {{ ref('raw_products') }}
)
select
    cast(product_id as integer) as product_id,
    cast(sku as varchar) as sku,
    cast(brand as varchar) as brand,
    cast(model_name as varchar) as model_name,
    cast(size_spec as varchar) as size_spec,
    cast(category as varchar) as product_category,
    cast(cost_price as double precision) as cost_price,
    cast(retail_price as double precision) as retail_price
from source
