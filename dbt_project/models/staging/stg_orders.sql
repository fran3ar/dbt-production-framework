with source as (
    select * from {{ ref('raw_orders') }}
)
select
    cast(order_id as varchar) as order_id,
    cast(customer_id as varchar) as customer_id,
    cast(product_id as integer) as product_id,
    cast(order_status as varchar) as order_status,
    cast(unit_qty as integer) as unit_qty,
    cast(unit_sale_price as double precision) as unit_sale_price,
    cast(order_timestamp as timestamp) as order_timestamp
from source
