{{ config (
    materialized="table"
)}}

{{ calendar_generation(
    datepart="day",
    start_date="cast('2010-01-01' as date)",
    end_date="cast('2050-12-31' as date)"
   )
}}

/* calendar_generation 

dbt_utils.date_spine
*/