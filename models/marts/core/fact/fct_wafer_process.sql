-- fct_wafer_process.sql

with int_wafer_process as (

    select * from {{ ref('int_wafer_process') }}

)

select
    wafer_id,
    timestamp,
    batch_id,
    lot_id,
    equipment_id,
    process_id,
    yield_percentage,
    yield_loss,
    defect_count,
    is_defective,
    process_duration,
    energy_consumption,
    temperature_actual,
    pressure_actual,
    pressure_status,
    process_type,
    target_temperature,
    target_pressure,
    priority_level,
    customer_id,
    process_month,
    day_of_week,
    yield_performance
from int_wafer_process