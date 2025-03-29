--int_production_runs__product.sql

{{
    config(
        tags=['core', 'intermediate']
    )
}}

with product_sources as (

    select distinct
        wafer_type,
        product_type
    from {{ ref('stg_production_source__production_runs') }}

),

-- Enrich with product performance metrics
product_metrics as (

    select
        wafer_type,
        product_type,
        avg(yield_rate) as avg_yield_rate,
        stddev(yield_rate) as yield_rate_stddev,
        avg(defect_count) as avg_defect_count,
        avg(cycle_time) as avg_cycle_time,
        count(distinct run_id) as production_run_count
    from {{ ref('stg_production_source__production_runs') }}
    group by wafer_type, product_type

),

final as (

    select
        -- Generate a unique product key
        {{ dbt_utils.generate_surrogate_key(['ps.wafer_type', 'ps.product_type']) }} as product_key,
        ps.wafer_type,
        ps.product_type,

        -- Create a product name for reporting
        ps.wafer_type || ' ' || ps.product_type as product_name,

        -- Add standard wafer diameter in mm
        case
            when ps.wafer_type = '200mm' then 200
            when ps.wafer_type = '300mm' then 300
            else null
        end as wafer_diameter_mm,

        -- Add product category
        case
            when ps.product_type = 'Logic' then 'Logic Chips'
            when ps.product_type = 'Memory' then 'Memory Chips'
            when ps.product_type = 'Analog' then 'Analog Chips'
            else 'Other'
        end as product_category,

        -- Add product complexity level (for reporting)
        case
            when ps.product_type = 'Logic' then 'High'
            when ps.product_type = 'Memory' then 'Medium'
            when ps.product_type = 'Analog' then 'Medium'
            else 'Low'
        end as complexity_level,

        -- Add performance metrics
        pm.avg_yield_rate,
        pm.yield_rate_stddev,
        pm.avg_defect_count,
        pm.avg_cycle_time,
        pm.production_run_count,

        -- Create quality tier based on yield
        case
            when pm.avg_yield_rate > 0.95 then 'Tier 1'
            when pm.avg_yield_rate > 0.90 then 'Tier 2'
            when pm.avg_yield_rate > 0.85 then 'Tier 3'
            else 'Tier 4'
        end as quality_tier,

        -- Current timestamp for SCD tracking
        current_timestamp as valid_from,
        null::timestamp as valid_to,
        true as is_current
    from product_sources ps
    left join product_metrics pm
        on ps.wafer_type = pm.wafer_type
        and ps.product_type = pm.product_type

)

select * from final