{{ config (
    materialized="table"
)}}

With pivoted as (
{{ dbt_utils.unpivot(table=ref('constants')) }}
)

Select  * from pivoted