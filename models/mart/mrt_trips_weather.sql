{%- set current_year = modules.datetime.date.today().year -%}
{%- set year_range = get_noaa_years() -%}

{%- if current_year in year_range -%}
    {%- set filter_year = current_year -%}
    {{ log("Current year present in dataset. Table 'trips_weather for current year " ~ filter_year ~ " generated", info=True) }}
{%- else -%}
    {%- set filter_year = year_range[-1] -%}
    {{ log("Current year not in dataset. Table 'trips_weather' generated for " ~ filter_year, info=True) }}
{%- endif -%}

with
trips as (
    select
        *
    from
        {{ ref("int_chicago_taxi__trips_daily")}}
    where
        date_trunc(trip_date, year) = date('{{ filter_year }}-01-01')
),

weather as (
    select
        *
    from
        {{ ref("int_noaa__gsod_daily")}}
    where
        date_trunc(date, year) = date('{{ filter_year }}-01-01')
),

joined as (
    select
        -- calendar
        a.trip_date as `date`,
        extract(year from a.trip_date) as year,
        extract(month from a.trip_date) as month,
        extract(day from a.trip_date) as day,
        cast(format_date('%u', a.trip_date) as int64) as day_of_week,

        -- taxi metrics
        a.total_trips,
        round(a.avg_trip_seconds, 2) as avg_trip_seconds,
        round(a.sum_trip_miles, 2) as sum_trip_miles,
        round(a.avg_trip_miles, 2) as avg_trip_miles,
        round(a.avg_trip_total, 2) as avg_trip_total,
        round(a.sum_trip_total, 2) as sum_trip_total,

        -- weather metrics
        b.station_count as weather_station_count,
        round(b.avg_temperature,2) as avg_temperature,
        round(b.avg_max_temperature, 2) as avg_max_temperature,
        round(b.avg_min_temperature, 2) as avg_min_temperature,
        round(b.avg_precipitation, 2) as avg_precipitation,
        round(b.avg_wind_speed, 2) as avg_wind_speed,
        round(b.max_wind_gust, 2) as max_wind_gust,
        round(b.max_snow_depth, 1) as max_snow_depth
    from
        trips as a left join weather as b on a.trip_date = b.date
)

select * from joined