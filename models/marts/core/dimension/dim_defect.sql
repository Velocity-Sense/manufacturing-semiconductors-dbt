-- dim_defect.sql

with stg_defects as (

    select * from {{ ref('stg_defects') }}

),

dim_defect as (

    select
        defect_id,
        initcap(trim(defect_type)) as defect_type,
        lower(trim(defect_category)) as defect_category,
        trim(defect_description) as defect_description,
        trim(potential_causes) as potential_causes,
        severity_level,
        case
            when severity_level <= 2 then 'Low'
            when severity_level = 3 then 'Moderate'
            else 'High'
        end as severity_rating
    from stg_defects

)

select * from dim_defect