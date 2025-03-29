-- dim_inventory_supplies.sql

with dim_inventory_supplies as (

    select * from {{ ref('int_inventory_supplies__items') }}

)

select * from dim_inventory_supplies