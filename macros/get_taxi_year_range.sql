{% macro get_taxi_year_range() %}

    {% set taxi_source = source("chicago_taxi_trips", "taxi_trips") %}

    {% set sql %}
        select
            extract(year from max(trip_start_timestamp)) as max_year,
            extract(year from min(trip_start_timestamp)) as min_year,
        from {{ taxi_source }}
    {% endset %}

    {% set result = run_query(sql) %}

    {% if execute %}
        {% set max_year = result.columns["max_year"].values()[0] %}
        {% set min_year = result.columns["min_year"].values()[0] %}
        {% set year_range = range(min_year, max_year + 1) | list %}
        {{ log("Taxi trips range: " ~ year_range, info=True) }}
    {% else %}
        {% set year_range = [] %}
    {% endif %}

    {{ return(year_range) }}
{% endmacro %}
