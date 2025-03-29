-- int_operator_logs__operator.sql

{{
    config(
        tags=['core', 'intermediate']
    )
}}

with operator_source as (

    select distinct
        operator_id,
        operator_level
    from {{ ref('stg_operators_source__operator_logs') }}

),

-- Operator activity and performance metrics
operator_metrics as (

    select
        operator_id,
        count(distinct log_id) as total_logs,
        count(distinct machine_id) as machines_operated,
        count(distinct case when log_type = 'Alert' then log_id end) as alerts_logged,
        count(distinct case when log_type = 'Action' then log_id end) as actions_taken,
        count(distinct case when action_taken != 'None' then log_id end) as interventions_count
    from {{ ref('stg_operators_source__operator_logs') }}
    group by operator_id

),

-- Joining with production data to get performance impact
operator_impact as (

    select
        ol.operator_id,
        avg(pr.yield_rate) as supervised_yield_rate,
        sum(pr.defect_count) as total_supervised_defects,
        count(distinct pr.run_id) as supervised_runs
    from {{ ref('stg_operators_source__operator_logs') }} ol
    inner join {{ ref('stg_production_source__production_runs') }} pr
        on ol.machine_id = pr.machine_id
        and date(ol.log_timestamp) = pr.production_date
    group by ol.operator_id

),

final as (

    select
        os.operator_id,
        os.operator_level,

        -- Experience level mapping for reporting
        case
            when os.operator_level = 'Junior' then 1
            when os.operator_level = 'Senior' then 2
            when os.operator_level = 'Lead' then 3
            else 0
        end as experience_level,

        -- Activity metrics
        om.total_logs,
        om.machines_operated,
        om.alerts_logged,
        om.actions_taken,
        om.interventions_count,

        -- Responsiveness metric (actions taken / alerts)
        case
            when om.alerts_logged = 0 then null
            else om.actions_taken::float / om.alerts_logged
        end as response_rate,

        -- Impact metrics
        oi.supervised_yield_rate,
        oi.total_supervised_defects,
        oi.supervised_runs,

        -- Defect per run metric
        case
            when oi.supervised_runs = 0 then null
            else oi.total_supervised_defects::float / oi.supervised_runs
        end as defects_per_run,

        -- Performance rating
        case
            when oi.supervised_yield_rate > 0.95 then 'High Performer'
            when oi.supervised_yield_rate > 0.90 then 'Good Performer'
            when oi.supervised_yield_rate > 0.85 then 'Average Performer'
            else 'Needs Training'
        end as performance_rating,

        -- Current timestamp for SCD tracking
        current_timestamp as valid_from,
        null::timestamp as valid_to,
        true as is_current
    from operator_source os
    left join operator_metrics om on os.operator_id = om.operator_id
    left join operator_impact oi on os.operator_id = oi.operator_id

)

select * from final