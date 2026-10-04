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
                    from {{ ref("stg_noaa__stations") }}
                    where
                        st_distance(
                            st_geogpoint(longitude, latitude),
                            st_geogpoint(-87.623177, 41.881832)
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
            cast(count_wdsp as int64) as count_wind_speed,
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
    )

select *
from renamed
