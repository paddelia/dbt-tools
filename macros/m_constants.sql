{% macro m_constants(v_sysdate) %}

{% set v_Time %} Current_timestamp {% endset %}
{% set v_d %} 
        {%- if v_sysdate is defined -%}
            '{{v_sysdate}}'
        {%- else -%}
           {{v_Time}}
        {% endif -%}
 {% endset %}


{% set v_MonthWhenToResetHistory %} 2 {% endset %} --- Complication: this will control when the procedure remove the first year and fill the new year, will have to change back to 1 in march

Select 
Case when DATE_PART(mm, {{v_d}}::date) <= {{v_MonthWhenToResetHistory}} Then
TO_VARCHAR( {{v_d}}::date, 'yyyy') -1::char(4) || lpad(1, 2, 0)  
else
TO_VARCHAR( {{v_d}}::date, 'yyyy') ::char(4) || lpad(1, 2, 0) END as YYYYMM_JAN_Minus_1Y

, Case when DATE_PART(mm, {{v_d}}::date) <= {{v_MonthWhenToResetHistory}} Then
TO_VARCHAR( {{v_d}}::date, 'yyyy') -2::char(4) || lpad(1, 2, 0)  
else
TO_VARCHAR( {{v_d}}::date, 'yyyy') -1::char(4) || lpad(1, 2, 0) END as YYYYMM_JAN_Minus_2Y

, Case when DATE_PART(mm, {{v_d}}::date) <= {{v_MonthWhenToResetHistory}} Then
TO_VARCHAR( {{v_d}}::date, 'yyyy') -3::char(4) || lpad(1, 2, 0)  
else
TO_VARCHAR( {{v_d}}::date, 'yyyy') -2::char(4) || lpad(1, 2, 0) END as YYYYMM_JAN_Minus_3Y

, Case when DATE_PART(mm, {{v_d}}::date) <= {{v_MonthWhenToResetHistory}} Then
TO_VARCHAR( {{v_d}}::date, 'yyyy') -1::char(4) || lpad(101, 4, 0)  
else
TO_VARCHAR( {{v_d}}::date, 'yyyy') ::char(4) || lpad(101, 4, 0) END as YYYYMMDD_JAN_Minus_1Y

, Case when DATE_PART(mm, {{v_d}}::date) <= {{v_MonthWhenToResetHistory}} Then
TO_VARCHAR( {{v_d}}::date, 'yyyy') -2::char(4) || lpad(101, 4, 0)  
else
TO_VARCHAR( {{v_d}}::date, 'yyyy') -1::char(4) || lpad(101, 4, 0) END as YYYYMMDD_JAN_Minus_2Y

, Case when DATE_PART(mm, {{v_d}}::date) <= {{v_MonthWhenToResetHistory}} Then
TO_VARCHAR( {{v_d}}::date, 'yyyy') -3::char(4) || lpad(101, 4, 0)  
else
TO_VARCHAR( {{v_d}}::date, 'yyyy') -2::char(4) || lpad(101, 4, 0) END as YYYYMMDD_JAN_Minus_3Y

,  CAST( TO_VARCHAR({{v_d}}::date,'YYYYMMDD') AS int) as ID_Date
, to_date(To_char({{v_d}}::date, 'YYYY-MM-DD')) as Today_Date
, CAST( TO_VARCHAR( dateadd(day, -1, {{v_d}}::date),'YYYYMMDD') AS int) as ID_DateMinus1
, CAST( TO_VARCHAR({{v_d}}::date,'YYYY') AS int) as YYYY
, CAST( TO_VARCHAR({{v_d}}::date,'YYYYMM') AS int) YYYYMM
, CAST( TO_VARCHAR({{v_d}}::date,'YYYYMM') || lpad(Week({{v_d}}::date), 2, 0) AS int) YYYYMMWW

, CAST(TO_VARCHAR(DATEADD(MONTH, 1, {{v_d}}::date), 'yyyyMM' ) AS int)as YYYYMM_Plus1					
, CAST(TO_VARCHAR(DATEADD(MONTH, 2, {{v_d}}::date), 'yyyyMM' )AS int) as YYYYMM_Plus2				
, CAST(TO_VARCHAR(DATEADD(MONTH, 3, {{v_d}}::date), 'yyyyMM' )AS int) as YYYYMM_Plus3	
, CAST(TO_VARCHAR( {{v_d}}::date, 'yyyy' ) -1AS int) as YYYY_Minus1
, CAST(TO_VARCHAR( {{v_d}}::date, 'yyyy' ) +1AS int) as YYYY_Plus1
, cast( TO_VARCHAR( {{v_d}}::date, 'yyyy' ) || DATE_PART(QUARTER, {{v_d}}::date) AS int) as YYYYQ
, cast( CASE when DATE_PART(QUARTER, {{v_d}}::date) = 1 THEN TO_VARCHAR( {{v_d}}::date, 'yyyy' ) -1 + '4'
			ELSE TO_VARCHAR( {{v_d}}::date, 'yyyy' ) || DATE_PART(QUARTER, {{v_d}}::date) -1 
			END AS int) as YYYYQ_Minus1
, cast( CASE when DATE_PART(QUARTER, {{v_d}}::date) = 4 THEN TO_VARCHAR( {{v_d}}::date, 'yyyy' ) +1 + '1'
			ELSE TO_VARCHAR( {{v_d}}::date, 'yyyy' ) || DATE_PART(QUARTER, {{v_d}}::date) +1 
			END AS int) as YYYYQ_Plus1
, TO_VARCHAR( {{v_d}}::date, 'MON' ) as MMM
, TO_VARCHAR(DATEADD(MONTH, -1, {{v_d}}::date), 'MON' ) as MMM_Minus1
, TO_VARCHAR( {{v_d}}::date, 'MMMM' ) as MMMM
, case dayname( {{v_d}}::date)
        when 'Mon' then 'Monday'
        when 'Tue' then 'Tuesday'
        when 'Wed' then 'Wednesday'
        when 'Thu' then 'Thursday'
        when 'Fri' then 'Friday'
        when 'Sat' then 'Saturday'
        when 'Sun' then 'Sunday'
    end as DayOfWeekName
, DAYNAME( {{v_d}}::date) AS DayOfWeekNameShort
, CAST( DATE_PART(dw, {{v_d}}::date) AS int) AS DayOfWeek
, CAST( CASE WHEN DAYNAME({{v_d}}::date) NOT IN('Sat', 'Sun') THEN 1 ELSE 0 END AS Tinyint) AS IsWeekDay
, CAST( CASE WHEN DAYNAME({{v_d}}::date) IN('Sat', 'Sun') THEN 1 ELSE 0 END AS Tinyint) AS IsWeekEndDay
, CAST( CASE WHEN DAYNAME({{v_d}}::date) = 'Fri' THEN 1 ELSE 0 END AS Tinyint) AS IsFriday

, CAST( DATE_PART(wk, {{v_d}}::date) AS int) AS WeekOfYear
, CAST( DATE_PART(mm, {{v_d}}::date) AS int) AS MonthOfYear
, CAST( CASE WHEN DATE_PART(mm, {{v_d}}::date) <> DATE_PART(mm, DATEADD(dd, 1, {{v_d}}::date)) THEN 1 ELSE 0 END AS Tinyint) AS IsLastDayOfMonth
, CAST( DATE_PART(quarter, {{v_d}}::date) AS int) AS CalendarQuarter
, CAST( CASE WHEN DATE_PART(mm, {{v_d}}::date) < 7 THEN 1 ELSE 2 END AS int) AS CalendarSemester
, CAST( DATE_PART(yy, {{v_d}}::date) AS int) AS CalendarYear
/*Fiscal dates not yet implemented as per fiscal calendar like 445
, CAST( DATE_PART(mm, {{v_d}}::date) AS int) AS FiscalMonthOfYear
, CAST( DATE_PART(quarter, {{v_d}}::date) AS int) AS FiscalQuarter
*/
, CAST( CASE WHEN DATE_PART(mm, {{v_d}}::date) < 7 THEN 1 ELSE 2 END AS int) AS FiscalSemester
, CAST( DATE_PART(yy, {{v_d}}::date) AS int) AS FiscalYear 
, datediff(day, trunc(to_date({{v_d}}::date), 'MONTH'), last_day({{v_d}}::date)) +1 AS DaysInMonth
, trunc(to_date({{v_d}}::date), 'MONTH') as FirstOfMonth
, trunc(to_date({{v_d}}::date), 'year') as FirstOfYear

, 'aptitive.us-east-1' as SnowSandbox
, TO_VARCHAR(DATEADD(MONTH, -36, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus36
, TO_VARCHAR(DATEADD(MONTH, -24, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus24
, TO_VARCHAR(DATEADD(MONTH, -18, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus18
, TO_VARCHAR(DATEADD(MONTH, -12, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus12
, TO_VARCHAR(DATEADD(MONTH, -9, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus9
, TO_VARCHAR(DATEADD(MONTH, -6, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus6
, TO_VARCHAR(DATEADD(MONTH, -3, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus3
, TO_VARCHAR(DATEADD(MONTH, -2, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus2
, TO_VARCHAR(DATEADD(MONTH, -1, {{v_d}}::date), 'yyyyMM' )::INT as YYYYMM_Minus1
, trunc({{v_d}}::date, 'MONTH') as First_Day_Of_Month_Date
, last_day({{v_d}}::date) as Last_Day_Of_Month_Date

{%- endmacro %}
