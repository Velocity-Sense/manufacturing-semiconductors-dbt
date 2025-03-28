-- base_operators_source__operator_logs.sql

with source as (
    
    select * from {{ source('operators_source', 'operator_logs') }}

),

renamed as (
    
    select
        log_id,
        operator_id,
        operator_level,
        shift,
        machine_id,
        machine_type,
        timestamp as log_timestamp,
        DATE(timestamp) as log_date,
        -- Extract time parts for time-based analysis
        EXTRACT(HOUR FROM timestamp) as log_hour,
        EXTRACT(DOW FROM timestamp) as day_of_week,
        log_type,
        log_message,
        action_taken,
        -- Flag maintenance actions
        action_taken != 'None' as has_action,
        -- Categorize log severity
        CASE
            WHEN log_type = 'Alert' THEN 'High'
            WHEN log_type = 'Action' THEN 'Medium'
            ELSE 'Low'
        END as log_severity,
        -- Flag potential issues based on log messages
        CASE
            WHEN log_message LIKE '%vibration%' THEN TRUE
            WHEN log_message LIKE '%temperature%' THEN TRUE
            WHEN log_message LIKE '%spike%' THEN TRUE
            ELSE FALSE
        END as potential_issue_flag
    from source

)

select * from renamed