-- dim_lot.sql

with stg_lots as (

    select * from {{ ref('stg_lots') }}

),

dim_lot as (

    select
        lot_id,
        product_id,
        wafer_count,
        start_date,
        target_completion_date,
        customer_id,
        upper(trim(priority_level)) as priority_level,
        -- time allowed for completion
        target_completion_date - start_date as scheduled_duration_days
    from stg_lots

)

select * from dim_lot