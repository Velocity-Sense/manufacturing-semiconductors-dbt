-- int_inventory_supplies__items.sql

{{
    config(
        tags=['core', 'intermediate']
    )
}}

with inventory_source as (

    select distinct
        item_id,
        item_name,
        category,
        unit
    from {{ ref('stg_inventory_source__inventory_supplies') }}

),

-- Item usage and cost metrics
item_metrics as (

    select
        item_id,
        avg(case when transaction_type = 'IN' then unit_cost end) as avg_unit_cost,
        sum(case when transaction_type = 'IN' then quantity else 0 end) as total_in_quantity,
        sum(case when transaction_type = 'OUT' then quantity else 0 end) as total_out_quantity,
        sum(case when transaction_type = 'IN' then total_cost else 0 end) as total_in_cost,
        sum(case when transaction_type = 'OUT' then total_cost else 0 end) as total_out_cost,
        max(stock_level_after) as latest_stock_level,
        count(distinct case when is_low_stock then transaction_id end) as low_stock_incidents
    from {{ ref('stg_inventory_source__inventory_supplies') }}
    group by item_id

),

inventory_supplies as (
    select
        item_id,
        transaction_date,
        sum(case when transaction_type = 'OUT' then quantity else 0 end) as total_out_quantity,
        max(stock_level_after) as latest_stock_level
    from {{ ref('stg_inventory_source__inventory_supplies') }}
    group by item_id, transaction_date
),

-- Calculate usage patterns and inventory health metrics
inventory_health_stg as (

    select
        item_id,
        -- Calculate average daily consumption
        total_out_quantity / nullif(count(distinct transaction_date), 0) as avg_daily_consumption,
        -- Calculate days of supply left
        latest_stock_level / nullif(total_out_quantity / nullif(count(distinct transaction_date), 0), 0) as days_of_supply
    from
        inventory_supplies
    group by item_id, latest_stock_level, total_out_quantity

),

inventory_health as (
    select
        *,
        case when days_of_supply < 7 then true else false end as needs_reorder
    from
        inventory_health_stg
),

final as (

    select
        inv.item_id,
        inv.item_name,
        inv.category,
        inv.unit,

        -- Add item criticality based on category
        case
            when inv.category = 'Raw Material' then 'High'
            when inv.category = 'Chemical' then 'High'
            when inv.category = 'Spare Part' then 'Medium'
            else 'Low'
        end as item_criticality,

        -- Cost category based on average unit cost
        case
            when im.avg_unit_cost > 30 then 'High Cost'
            when im.avg_unit_cost > 15 then 'Medium Cost'
            else 'Low Cost'
        end as cost_category,

        -- Usage metrics
        im.avg_unit_cost,
        im.total_in_quantity,
        im.total_out_quantity,
        im.total_in_cost,
        im.total_out_cost,
        im.latest_stock_level,
        im.low_stock_incidents,

        -- Inventory health
        ih.avg_daily_consumption,
        ih.days_of_supply,
        ih.needs_reorder,

        -- Inventory status
        case
            when ih.days_of_supply < 3 then 'Critical'
            when ih.days_of_supply < 7 then 'Low'
            when ih.days_of_supply < 14 then 'Moderate'
            else 'Healthy'
        end as inventory_status,

        -- Current timestamp for SCD tracking
        current_timestamp as valid_from,
        null::timestamp as valid_to,
        true as is_current
    from inventory_source inv
    left join item_metrics im on inv.item_id = im.item_id
    left join inventory_health ih on inv.item_id = ih.item_id

)

select * from final