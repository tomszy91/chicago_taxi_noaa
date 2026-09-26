{% set noaa_years = get_noaa_years() %}

with
    source as (
        {% for year in noaa_years %}
            select
                stn,
                wban,
                year,
                mo,
                da,
                temp,
                count_temp,
                dewp,
                count_dewp,
                slp,
                count_slp,
                stp,
                count_stp,
                visib,
                count_visib,
                wdsp,
                count_wdsp,
                mxpsd,
                gust,
                max,
                min,
                prcp,
                sndp,
                flag_max,
                flag_min,
                flag_prcp,
                fog,
                rain_drizzle,
                snow_ice_pellets,
                hail,
                thunder,
                tornado_funnel_cloud,
            from {{ source("noaa_gsod", "gsod" ~ year) }}
            where
                concat(stn, "_", wban) in (
                    select concat(usaf, "_", wban) as stn_wban
                    from `bigquery-public-data.noaa_gsod.stations`
                    where
                        st_distance(
                            st_geogpoint(lon, lat), st_geogpoint(-87.623177, 41.881832)
                        )
                        <= 30000
                )
            {%- if not loop.last %}
                union all
            {%- endif -%}
        {%- endfor -%}
    ),

    renamed as (
        select
            cast(stn as string) as stn,
            cast(wban as string) as wban,
            concat(stn, "_", wban) as stn_wban,
            timestamp(
                date(cast(year as int64), cast(mo as int64), cast(da as int64))
            ) as date,
            cast(year as int64) as year,
            cast(mo as int64) as month,
            cast(da as int64) as day,
            cast(temp as float64) as mean_temperature,
            cast(count_temp as int64) as count_temperature,
            cast(dewp as float64) as mean_dew_point,
            cast(count_dewp as int64) as count_dew_point,
            cast(slp as float64) as mean_sea_level_pressure,
            cast(count_slp as int64) as count_sea_level_pressure,
            cast(stp as float64) as mean_station_pressure,
            cast(count_stp as int64) as count_station_pressure,
            cast(visib as float64) as mean_visibility,
            cast(count_visib as int64) as count_visibility,
            cast(wdsp as string) as mean_wind_speed,
            cast(count_wdsp as string) as count_wind_speed,
            cast(mxpsd as string) as max_wind_speed,
            cast(gust as float64) as max_wind_gust,
            cast(max as float64) as max_temperature,
            cast(flag_max as string) as flag_max_temperature,
            cast(min as float64) as min_temperature,
            cast(flag_min as string) as flag_min_temperature,
            cast(prcp as float64) as precipitation,
            cast(flag_prcp as string) as flag_precipitation,
            cast(sndp as float64) as snow_depth,
            cast(fog as string) as fog,
            cast(rain_drizzle as string) as rain_drizzle,
            cast(snow_ice_pellets as string) as snow_ice_pellets,
            cast(hail as string) as hail,
            cast(thunder as string) as thunder,
            cast(tornado_funnel_cloud as string) as tornado_funnel_cloud
        from source
    ),

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
        from renamed
    )

select *
from cleared
