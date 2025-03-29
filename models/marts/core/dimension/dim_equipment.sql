-- dim_equipment.sql

with stg_equipment as (

    select * from {{ ref('stg_equipment') }}

),

dim_equipment as (

    select
        equipment_id,
        initcap(trim(equipment_type)) as equipment_type,
        initcap(trim(manufacturer)) as manufacturer,
        upper(trim(model_number)) as model_number,
        installation_date,
        last_maintenance_date,
        upper(trim(location)) as location,
        -- calculate equipment age in years
        date_part('year', current_date) - date_part('year', installation_date) as equipment_age_years
    from stg_equipment

)

select * from dim_equipment