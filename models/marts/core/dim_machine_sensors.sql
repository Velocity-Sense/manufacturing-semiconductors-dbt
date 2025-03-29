-- dim_machine_sensors.sql

with dim_machine_sensors as (

    select * from {{ ref('int_machine_sensors__machine') }}

)

select * from dim_machine_sensors