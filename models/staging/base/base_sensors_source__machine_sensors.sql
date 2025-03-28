-- base_sensors_source__machine_sensors.sql

with source as (
    
    select * from {{ source('sensors_source', 'machine_sensors') }}

),

renamed as (
    
    select
        reading_id,
        machine_id,
        machine_type,
        sensor_type,
        timestamp as reading_timestamp,
        DATE(timestamp) as reading_date,
        -- Extract time parts for time-based analysis
        EXTRACT(HOUR FROM timestamp) as reading_hour,
        EXTRACT(DOW FROM timestamp) as day_of_week,
        value as sensor_value,
        unit as measurement_unit,
        status,
        -- Flag anomalies based on sensor type
        CASE
            WHEN sensor_type = 'Temp' AND value > 110 THEN TRUE
            WHEN sensor_type = 'Vibration' AND value > 115 THEN TRUE
            WHEN sensor_type = 'Voltage' AND (value < 90 OR value > 110) THEN TRUE
            ELSE FALSE
        END as is_anomaly,
        -- Create a severity ranking
        CASE 
            WHEN status = 'FAIL' THEN 3
            WHEN status = 'WARN' THEN 2
            WHEN status = 'OK' THEN 1
            ELSE 0
        END as severity_rank
    from source

)

select * from renamed