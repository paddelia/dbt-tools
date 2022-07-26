{%- docs constants %}
	
This is the markdown for
constants.
Use constants example

Select p.* from stg_payment p
Cross join constants c 
Where 
left(p.Created_YYYYMMDD,6) between c.YYYYMM_JAN_MINUS_1Y and YYYYMM_MINUS1

Select p.* from stg_payment p
Cross join constants c 
Where 
Created_at = c.FIRSTOFYEAR

{% enddocs -%}

{% docs calendar %}

Calendar as a base dimension, including holidays and easter day.
Calendar uses dbt_utils.date_spine

{% enddocs %}