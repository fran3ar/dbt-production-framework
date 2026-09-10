with orders as (
    select * from {{ ref('stg_orders') }}
),
products as (
    select * from {{ ref('d_tire_product') }}
)
select
    o.order_id,
    o.customer_id,
    o.product_id,
    p.brand,
    p.model_name,
    o.order_status,
    o.unit_qty,
    o.unit_sale_price,
    round(cast(o.unit_qty * o.unit_sale_price as numeric), 2) as total_gross_revenue,
    round(cast(o.unit_qty * (o.unit_sale_price - p.cost_price) as numeric), 2) as realized_gross_margin,
    o.order_timestamp
from orders o
inner join products p on o.product_id = p.product_id
