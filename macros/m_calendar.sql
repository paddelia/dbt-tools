{% macro get_intervals_between(start_date, end_date, datepart) -%}
    {{ return(adapter.dispatch('get_intervals_between', 'dbt_utils')(start_date, end_date, datepart)) }}
{%- endmacro %}

{% macro default__get_intervals_between(start_date, end_date, datepart) -%}
    {%- call statement('get_intervals_between', fetch_result=True) %}

        select {{datediff(start_date, end_date, datepart)}}

    {%- endcall -%}

    {%- set value_list = load_result('get_intervals_between') -%}

    {%- if value_list and value_list['data'] -%}
        {%- set values = value_list['data'] | map(attribute=0) | list %}
        {{ return(values[0]) }}
    {%- else -%}
        {{ return(1) }}
    {%- endif -%}

{%- endmacro %}

{% macro calendar_generation(datepart, start_date, end_date) %}
    {{ return(adapter.dispatch('date_spine', 'dbt_utils')(datepart, start_date, end_date)) }}
{%- endmacro %}

{% macro default__date_spine(datepart, start_date, end_date) %}

{# call as follows:

date_spine(
    "day",
    "to_date('01/01/2016', 'mm/dd/yyyy')",
    "dateadd(week, 1, current_date)"
) #}


with rawdata as (

    {{dbt_utils.generate_series(
        dbt_utils.get_intervals_between(start_date, end_date, datepart)
    )}}

),

all_periods as (

    select (
        {{
            dateadd(
                datepart,
                "row_number() over (order by 1) - 1",
                start_date
            )
        }}
    ) as date_{{datepart}}
    from rawdata

),

CalendarPart1 as (

    select cast(p.Date_Day as date) Day_Date
,   CAST( TO_VARCHAR(date_{{datepart}},'YYYYMMDD') AS int) AS IDdate
, to_Date(TO_VARCHAR( date_{{datepart}},'MM/DD/YYYY')) AS FullDate
, CAST( LEFT(TO_VARCHAR( date_{{datepart}},'YYYYMMDD'), 4) AS int) AS Year
,  CAST( CAST( DATE_PART(yy, date_{{datepart}}) as CHAR(4)) || CAST( DATE_PART(quarter, date_{{datepart}}) AS CHAR(1))  AS INT)  AS YearQuarter
, CAST( LEFT(TO_VARCHAR( date_{{datepart}},'YYYYMMDD'), 6) AS int) AS YearMonth

, CAST( LEFT(TO_VARCHAR( date_{{datepart}},'YYYYMMDD'), 6) 
    || lpad(CAST( DATE_PART(wk, date_{{datepart}}) AS varchar(2)), 2, 0) 
    AS int) AS YearWeek -- BUG will not stuff the week

/* the following is not correct 
,  CAST( CAST( DATE_PART(yy, date_{{datepart}}) AS char(4)) 
|| '0' 
|| CAST( DATE_PART(quarter, date_{{datepart}}) AS char(1)) 
+ CASE WHEN LENGTH(DATE_PART(mm, date_{{datepart}})) < 2 THEN '0' 
|| CAST( DATE_PART(mm, date_{{datepart}}) AS char(1)) 
        ELSE 
       CAST( DATE_PART(mm, date_{{datepart}}) AS char(2)) 
    END 
+ CASE WHEN LENGTH(DATE_PART(dd, date_{{datepart}})) < 2 THEN'0' 
|| CAST( DATE_PART(dd, date_{{datepart}}) AS char(1)) 
        ELSE 
         CAST( DATE_PART(dd, date_{{datepart}}) AS char(2)) 
    END

    AS char(10)) 
    AS YQMD
*/
, CAST( DATE_PART(dw, date_{{datepart}}) AS int) AS DayOfWeek
,  DAYNAME(date_{{datepart}}) AS DayOfWeekNameShort
,   case dayname( date_{{datepart}})
        when 'Mon' then 'Monday'
        when 'Tue' then 'Tuesday'
        when 'Wed' then 'Wednesday'
        when 'Thu' then 'Thursday'
        when 'Fri' then 'Friday'
        when 'Sat' then 'Saturday'
        when 'Sun' then 'Sunday'
    end as DayOfWeekName
, CAST( DATE_PART(dd, date_{{datepart}}) AS int) AS DayOfMonth
, to_char( date_{{datepart}}, 'MMMM') AS MonthName
, to_char( date_{{datepart}}, 'MON') AS MonthNameShort
, CAST( DATE_PART(dy, date_{{datepart}}) AS int) AS DayOfYear
, CAST( CASE WHEN DAYNAME(date_{{datepart}}) NOT IN('Sat', 'Sun') THEN 1 ELSE 0 END AS Tinyint) AS IsWeekDay
, CAST( CASE WHEN DAYNAME(date_{{datepart}}) IN('Sat', 'Sun') THEN 1 ELSE 0 END AS Tinyint) AS IsWeekEndDay
, CAST( CASE WHEN DAYNAME(date_{{datepart}}) = 'Fri' THEN 1 ELSE 0 END AS Tinyint) AS IsFriday
, CAST( DATE_PART(wk, date_{{datepart}}) AS int) AS WeekOfYear
, CAST( DATE_PART(mm, date_{{datepart}}) AS int) AS MonthOfYear
, CAST( CASE WHEN DATE_PART(mm, date_{{datepart}}) <> DATE_PART(mm, DATEADD(dd, 1, date_{{datepart}})) THEN 1 ELSE 0 END AS Tinyint) AS IsLastDayOfMonth
, CAST( DATE_PART(quarter, date_{{datepart}}) AS int) AS CalendarQuarter
, CAST( CASE WHEN DATE_PART(mm, date_{{datepart}}) < 7 THEN 1 ELSE 2 END AS int) AS CalendarSemester
, CAST( DATE_PART(yy, date_{{datepart}}) AS int) AS CalendarYear
/*Fiscal dates not yet implemented as per fiscal calendar like 445
, CAST( DATE_PART(mm, date_{{datepart}}) AS int) AS FiscalMonthOfYear
, CAST( DATE_PART(quarter, date_{{datepart}}) AS int) AS FiscalQuarter
*/
, CAST( CASE WHEN DATE_PART(mm, date_{{datepart}}) < 7 THEN 1 ELSE 2 END AS int) AS FiscalSemester
, CAST( DATE_PART(yy, date_{{datepart}}) AS int) AS FiscalYear 
, datediff(day, trunc(to_date(date_{{datepart}}), 'MONTH') , last_day(date_{{datepart}})) +1 AS DaysInMonth
, trunc(to_date(date_{{datepart}}), 'week') as FirstOfWeek
, last_day(to_date(date_{{datepart}}), 'week') as LastOfWeek
, trunc(to_date(date_{{datepart}}), 'MONTH') as FirstOfMonth
, last_day(to_date(date_{{datepart}}), 'MONTH') as LastOfMonth
, trunc(to_date(date_{{datepart}}), 'year') as FirstOfYear
, trunc(dateadd(week, -1, date_{{datepart}}), 'week')  as MinDateOfWeekMinus1  --- check this
---, trunc( date_{{datepart}}, 'week')  as MinDateOfWeekMinus1_2
, 0 as MaxDateOfWeekMinus1
, CAST( ROW_NUMBER() OVER(PARTITION BY trunc(to_date(date_{{datepart}}), 'MONTH'), CAST( DATE_PART(dw, date_{{datepart}}) AS int) ORDER BY p.Date_Day) AS TINYINT) as DOWInMonth
, CAST( ROW_NUMBER() OVER(PARTITION BY trunc(to_date(date_{{datepart}}), 'MONTH'), CAST( DATE_PART(dw, date_{{datepart}}) AS int) ORDER BY p.Date_Day DESC) AS TINYINT) as LastDOWInMonth
from all_periods p
    where date_{{datepart}} <= {{ end_date }}

)

, Holiday as (
Select 
CASE
  WHEN (fulldate = FirstOfYear) 
    THEN 1
  WHEN (DOWInMonth = 3 AND MonthName = 'January' AND DayOfWeekName = 'Monday')
    THEN 1    -- (3rd Monday in January)
  WHEN (DOWInMonth = 3 AND MonthName = 'February' AND DayOfWeekName = 'Monday')
    THEN 1         -- (3rd Monday in February)
  WHEN (LastDOWInMonth = 1 AND MonthName = 'May' AND DayOfWeekName = 'Monday')
    THEN 1              -- (last Monday in May)
  WHEN (MonthName = 'July' AND dayOfMonth = 4)
    THEN 1          -- (July 4th)
  WHEN (DOWInMonth = 1 AND MonthName = 'September' AND DayOfWeekName = 'Monday')
    THEN 1                -- (first Monday in September)
  WHEN (DOWInMonth = 2 AND MonthName = 'October' AND DayOfWeekName = 'Monday')
    THEN 1              -- Columbus Day (second Monday in October)
  WHEN (MonthName = 'November' AND dayOfMonth = 11)
    THEN 1            -- Veterans' Day (November 11th)
  WHEN (fulldate = 
      CAST(concat(d.YEAR,'-', 11,'-', 29) AS date) 
      - CAST( DATE_PART(dw, CAST(concat(d.YEAR,'-', 11,'-', 4) AS date)) AS int)
  ) THEN 1 -- Thanksgiving Day (fourth Thursday in November)

    WHEN (fulldate = 
      CAST(concat(d.YEAR,'-', 11,'-', 29) AS date) 
      - CAST( DATE_PART(dw, CAST(concat(d.YEAR,'-', 11,'-', 3) AS date)) AS int)
  ) THEN 1 -- BlackFriday Day after thanksgiving
  WHEN (MonthName = 'December' AND dayOfMonth = 25)
    THEN 1 Else 0
  END as  IsHoliday 
 , CASE
  WHEN (fulldate = FirstOfYear) 
    THEN 'New Year''s Day'
  WHEN (DOWInMonth = 3 AND MonthName = 'January' AND DayOfWeekName = 'Monday')
    THEN 'Martin Luther King Day'    -- (3rd Monday in January)
  WHEN (DOWInMonth = 3 AND MonthName = 'February' AND DayOfWeekName = 'Monday')
    THEN 'President''s Day'          -- (3rd Monday in February)
  WHEN (LastDOWInMonth = 1 AND MonthName = 'May' AND DayOfWeekName = 'Monday')
    THEN 'Memorial Day'              -- (last Monday in May)
  WHEN (MonthName = 'July' AND dayOfMonth = 4)
    THEN 'Independence Day'          -- (July 4th)
  WHEN (DOWInMonth = 1 AND MonthName = 'September' AND DayOfWeekName = 'Monday')
    THEN 'Labour Day'                -- (first Monday in September)
  WHEN (DOWInMonth = 2 AND MonthName = 'October' AND DayOfWeekName = 'Monday')
    THEN 'Columbus Day'              -- Columbus Day (second Monday in October)
  WHEN (MonthName = 'November' AND dayOfMonth = 11)
    THEN 'Veterans'' Day'            -- Veterans' Day (November 11th)
  WHEN (fulldate = 
      CAST(concat(d.YEAR,'-', 11,'-', 29) AS date) 
      - CAST( DATE_PART(dw, CAST(concat(d.YEAR,'-', 11,'-', 4) AS date)) AS int)
  ) THEN  'Thanksgiving Day'  -- Thanksgiving Day (fourth Thursday in November)
    WHEN (fulldate = 
      CAST(concat(d.YEAR,'-', 11,'-', 29) AS date) 
      - CAST( DATE_PART(dw, CAST(concat(d.YEAR,'-', 11,'-', 3) AS date)) AS int)
  ) THEN  'Black Friday'  -- BlackFriday Day after thanksgiving
  WHEN (MonthName = 'December' AND dayOfMonth = 25)
    THEN 'Christmas Day'
  END as HolidayText
  , d.*
  from CalendarPart1 d

)

select * from Holiday

{% endmacro %}
