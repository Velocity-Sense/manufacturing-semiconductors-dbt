-- dim_process.sql

with stg_process as (

    select * from {{ ref('stg_process') }}

),

dim_process as (

    select
        process_id,
        initcap(trim(process_name)) as process_name,
        lower(trim(process_type)) as process_type,
        recipe_id,
        expected_duration,
        material_requirements,
        target_temperature,
        target_pressure,
        -- add complexity bucket based on expected_duration
        case
            when expected_duration < 8 then 'Low'
            when expected_duration < 15 then 'Medium'
            else 'High'
        end as process_complexity
FROM stg_process

)

select * from dim_process