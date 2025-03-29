-- stg_process.sql

with stg_process as (

    select * from {{ source('raw', 'process_data') }}

)

select
    process_id,
    process_name,
    process_type,
    recipe_id,
    expected_duration,
    material_requirements,
    -- extract temp and pressure from text field
    split_part(split_part(target_parameters, 'temp:', 2), ',', 1)::float as target_temperature,
    split_part(split_part(target_parameters, 'pressure:', 2), ',', 1)::float as target_pressure
from stg_process