-- dim_operator_logs.sql

with dim_operator_logs as (

    select * from {{ ref('int_operator_logs__operator') }}

)

select * from dim_operator_logs