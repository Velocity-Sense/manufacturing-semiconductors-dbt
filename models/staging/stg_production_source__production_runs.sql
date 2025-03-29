-- stg_production_source__production_runs.sql

with source as (
    
    select * from {{ source('production_source', 'production_runs') }}

),

renamed as (
    
    select
        run_id,
        machine_id,
        machine_type,
        wafer_type,
        product_type,
        timestamp as production_timestamp,
        DATE(timestamp) as production_date,
        -- Extract time parts for time-based analysis
        EXTRACT(HOUR FROM timestamp) as production_hour,
        EXTRACT(DOW FROM timestamp) as day_of_week,
        output_units,
        actual_output,
        yield_rate,
        defect_count,
        energy_consumption,
        cycle_time,
        -- Adding derived metrics
        CASE 
            WHEN yield_rate < {{ var('fail_threshold') }} THEN 'Critical'
            WHEN yield_rate < {{ var('warn_threshold') }} THEN 'Warning'
            ELSE 'Good'
        END as yield_status,
        CASE 
            WHEN energy_consumption > {{ var('high_energy_threshold') }} THEN 'High'
            ELSE 'Normal'
        END as energy_status
    from source

)

select * from renamed