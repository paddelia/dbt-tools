{{ dbt.listagg(measure="CountryCD2", delimiter_text="'|'", order_by_clause="CountryCD2", limit_num=10) }}