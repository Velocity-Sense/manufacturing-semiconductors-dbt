-- dim_production_runs.sql

with dim_production_runs as (

    select * from {{ ref('int_production_runs__product') }}

)

select * from dim_production_runs