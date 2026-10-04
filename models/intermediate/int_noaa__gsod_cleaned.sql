{{ config(
    partition_by={
        "field": "date",
        "data_type": "timestamp",
        "granularity": "year"
    }
) }}

with
    source as (select * from {{ ref("stg_noaa__gsod") }}),
    cleared as (
        select
            stn,
            wban,
            stn_wban,
            date,
            year,
            month,
            day,
            case
                when count_temperature = 0 then null else mean_temperature
            end as mean_temperature,
            count_temperature,
            case
                when count_dew_point = 0 then null else mean_dew_point
            end as mean_dew_point,
            count_dew_point,
            case
                when count_sea_level_pressure = 0 then null else mean_sea_level_pressure
            end as mean_sea_level_pressure,
            count_sea_level_pressure,
            case
                when count_station_pressure = 0
                then null
                else
                    case
                        when mean_station_pressure = 9999.9
                        then null
                        when
                            mean_station_pressure < 300
                            and mean_station_pressure >= 0
                            and mean_sea_level_pressure != 9999.9
                            and (
                                mean_sea_level_pressure - (mean_station_pressure + 1000)
                            )
                            between -5 and 60
                        then mean_station_pressure + 1000
                        when mean_station_pressure < 300
                        then null
                        else mean_station_pressure
                    end
            end as mean_station_pressure,
            count_station_pressure,
            case
                when count_visibility = 0 then null else mean_visibility
            end as mean_visibility,
            count_visibility,
            case
                when count_wind_speed = 0
                then null
                else cast(mean_wind_speed as float64)
            end as mean_wind_speed,
            count_wind_speed,
            case
                when count_wind_speed = 0 then null else cast(max_wind_speed as float64)
            end as max_wind_speed,
            case
                when count_wind_speed = 0 then null else max_wind_gust
            end as max_wind_gust,
            case
                when count_temperature = 0 then null else max_temperature
            end as max_temperature,
            flag_max_temperature,
            case
                when count_temperature = 0 then null else min_temperature
            end as min_temperature,
            flag_min_temperature,
            case
                when precipitation = 99.99 and flag_precipitation = 'I'
                then null
                when precipitation = 99.99 and flag_precipitation = 'H'
                then 0
                when precipitation = 99.99
                then null
                else precipitation
            end as precipitation,
            flag_precipitation,
            case
                when snow_depth = 999.9 and snow_ice_pellets = '0'
                then 0
                when snow_depth = 999.9
                then null
                else snow_depth
            end as snow_depth,
            case fog when '1' then true when '0' then false end as fog,
            case
                rain_drizzle when '1' then true when '0' then false
            end as rain_drizzle,
            case
                snow_ice_pellets when '1' then true when '0' then false
            end as snow_ice_pellets,
            case hail when '1' then true when '0' then false end as hail,
            case thunder when '1' then true when '0' then false end as thunder,
            case
                tornado_funnel_cloud when '1' then true when '0' then false
            end as tornado_funnel_cloud
        from source
    )

select *
from cleared
