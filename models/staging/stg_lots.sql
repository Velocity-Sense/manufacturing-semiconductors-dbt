-- stg_lots.sql

with stg_lots as (

    select * from {{ source('raw', 'lots') }}

)

select * from stg_lots