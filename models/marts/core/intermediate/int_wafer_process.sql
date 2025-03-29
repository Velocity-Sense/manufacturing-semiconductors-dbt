-- int_wafer_process.sql

with stg_wafer_process as (

    select * from {{ ref('stg_wafer_process') }}

),

stg_process as (

    select * from {{ ref('stg_process') }}

),

stg_lots as (

    select * from {{ ref('stg_lots') }}

),

int_wafer_process AS (

    select
        wp.wafer_id,
        wp.timestamp,
        wp.batch_id,
        wp.lot_id,
        wp.equipment_id,
        wp.process_id,
        wp.yield_percentage,
        wp.yield_loss,
        wp.defect_count,
        wp.is_defective,
        wp.process_duration,
        wp.energy_consumption,
        wp.temperature_actual,
        wp.pressure_actual,
        wp.pressure_status,
        p.process_type,
        p.target_temperature,
        p.target_pressure,
        l.priority_level,
        l.customer_id
    from stg_wafer_process wp
    left join stg_process p
        on wp.process_id = p.process_id
    left join stg_lots l
        on wp.lot_id = l.lot_id

)

select
    *,
    date_trunc('month', timestamp) as process_month,
    extract(dow from timestamp) as day_of_week,
    case
        when yield_loss < 2 then 'Excellent'
        when yield_loss < 5 then 'Good'
        else 'Needs Attention'
    end as yield_performance
from int_wafer_process