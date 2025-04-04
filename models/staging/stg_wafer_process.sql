-- stg_wafer_process

with stg_wafer_process as (

    select * from {{ source('raw', 'wafer_process_events') }}

)

select
    wafer_id,
    timestamp,
    batch_id,
    lot_id,
    equipment_id,
    process_id,
    defect_id,
    yield_percentage,
    100 - yield_percentage as yield_loss,
    defect_count,
    case when defect_count > 0 then true else false end as is_defective,
    process_duration,
    energy_consumption,
    temperature_actual,
    pressure_actual,
    -- bucketize pressure
    case
        when pressure_actual < 1.8 then 'Low'
        when pressure_actual < 2.2 then 'Normal'
        else 'High'
    end as pressure_status
from stg_wafer_process