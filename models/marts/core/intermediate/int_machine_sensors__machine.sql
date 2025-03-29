-- int_machine_sensors__machine.sql

{{
    config(
        tags=['core', 'intermediate']
    )
}}

with machine_sources as (

    select
        machine_id,
        machine_type
    from {{ ref('stg_production_source__production_runs') }}

    union distinct

    select
        machine_id,
        machine_type
    from {{ ref('stg_sensors_source__machine_sensors') }}

    union distinct

    select
        machine_id,
        machine_type
    from {{ ref('stg_operators_source__operator_logs') }}
),

distinct_machines as (

    select distinct
        machine_id,
        machine_type
    from machine_sources

),

-- Add machine metrics for enrichment
production_metrics as (

    select
        machine_id,
        avg(yield_rate) as avg_yield_rate,
        avg(energy_consumption) as avg_energy_consumption,
        avg(cycle_time) as avg_cycle_time,
        count(distinct run_id) as total_runs
    from {{ ref('stg_production_source__production_runs') }}
    group by machine_id

),

-- Add sensor metrics for enrichment
sensor_metrics as (

    select
        machine_id,
        count(distinct case when status != 'OK' then reading_id end) as total_non_ok_readings,
        count(distinct reading_id) as total_readings,
        count(distinct case when status != 'OK' then reading_id end) * 100.0 /
            nullif(count(distinct reading_id), 0) as non_ok_percentage
    from {{ ref('stg_sensors_source__machine_sensors') }}
    group by machine_id

),

final as (

    select
        dm.machine_id,
        dm.machine_type,

        -- Machine performance metrics from production data
        pm.avg_yield_rate,
        pm.avg_energy_consumption,
        pm.avg_cycle_time,
        pm.total_runs,

        -- Machine health metrics from sensor data
        sm.total_readings,
        sm.total_non_ok_readings,
        sm.non_ok_percentage,

        -- Machine health status derived from sensor data
        case
            when sm.non_ok_percentage > 5 then 'Needs Attention'
            when sm.non_ok_percentage > 1 then 'Monitor'
            else 'Good'
        end as machine_health_status,

        -- Machine efficiency rating based on production data
        case
            when pm.avg_yield_rate > 0.95 then 'High Efficiency'
            when pm.avg_yield_rate > 0.90 then 'Medium Efficiency'
            else 'Low Efficiency'
        end as efficiency_rating,

        -- Current timestamp for SCD tracking
        current_timestamp as valid_from,
        null::timestamp as valid_to,
        true as is_current
    from distinct_machines dm
    left join production_metrics pm on dm.machine_id = pm.machine_id
    left join sensor_metrics sm on dm.machine_id = sm.machine_id

)

select * from final