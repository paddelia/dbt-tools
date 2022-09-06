{{ config (
    materialized="table"
)}}

With Countries as (
    Select * 
    ,
	 (('http://www.geonames.org/flags/x/'|| lower(CountryCd2))||'.gif')  as CountryFlag 
    From public.Countries 
)

Select * from Countries