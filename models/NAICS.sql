{{ config (
    materialized="table"
)}}

With naics as (
    Select * 
, case Len(code) when 6 then 1 else 0 end  as isLeaf

    From public.naics 
)

Select * from naics