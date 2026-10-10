{% macro get_noaa_years() %}

    {% set available_noaa_years = range(2013, 2026) | list %}

    {% if not execute %}
        {{ return(available_noaa_years) }}
    {% endif %}

    {% set taxi_years = get_taxi_year_range() %}

    {% set missing_years = [] %}
    {% for year in taxi_years %}
        {% if year not in available_noaa_years %}
            {% do missing_years.append(year) %}
        {% endif %}
    {% endfor %}

    {% if missing_years | length > 0 %}
        {{ exceptions.raise_compiler_error(
                "MISSING NOAA SOURCE FOR YEARS: " ~ missing_years ~". Add them to _src_noaa_gsod.yml"
        )}}
    {% else %}
        {{ log("NOAA GSOD data covers taxi trips range", info=True) }}
    {% endif %}

    {{ return(taxi_years) }}
{% endmacro %}