-- stg_equipment.sql

with stg_equipment as (

    select * from {{ source('raw', 'equipment_logs') }}

)

select * from stg_equipment