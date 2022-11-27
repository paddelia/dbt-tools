{{ config (
    materialized="table"
)}}

With pivoted as (
{{ dbt_utils.unpivot(relation=ref('constants')) }}
)

Select  * from pivoted