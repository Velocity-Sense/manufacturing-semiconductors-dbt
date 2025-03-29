-- stg_inventory_source__inventory_supplies.sql

with source as (
    
    select * from {{ source('inventory_source', 'inventory_supplies') }}

),

renamed as (
    
    select
        transaction_id,
        item_id,
        item_name,
        category,
        transaction_type,
        quantity,
        unit,
        unit_cost,
        total_cost,
        timestamp as transaction_timestamp,
        DATE(timestamp) as transaction_date,
        -- Extract time parts for time-based analysis
        EXTRACT(HOUR FROM timestamp) as transaction_hour,
        EXTRACT(DOW FROM timestamp) as day_of_week,
        stock_level_after,
        -- Flag low stock levels based on category
        CASE
            WHEN category = 'Raw Material' AND stock_level_after < 200 THEN TRUE
            WHEN category = 'Spare Part' AND stock_level_after < 150 THEN TRUE
            WHEN category = 'Chemical' AND stock_level_after < 100 THEN TRUE
            ELSE FALSE
        END as is_low_stock,
        -- Add transaction direction
        CASE
            WHEN transaction_type = 'IN' THEN 1
            WHEN transaction_type = 'OUT' THEN -1
            ELSE 0
        END as transaction_multiplier
    from source

)

select * from renamed