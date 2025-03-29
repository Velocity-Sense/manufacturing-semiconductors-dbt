-- stg_defects.sql

with stg_defects as (

    select * from {{ source('raw', 'defect_logs') }}

)

select * from stg_defects