-- stg_process.sql

with stg_process as (

    select * from {{ source('raw', 'process_data') }}

)

select
    *,
    -- handle empty values with nullif before casting to float
    nullif(split_part(split_part(target_parameters, 'temp:', 2), ',', 1), '')::float as target_temperature,
    nullif(split_part(split_part(target_parameters, 'pressure:', 2), ',', 1), '')::float as target_pressure
from stg_process