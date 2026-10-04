with
source as (
    select * from {{ ref("int_noaa__gsod_cleaned")}}
),

daily as (
    select
        date,
        count(distinct stn_wban) as station_count,
      
        avg(mean_temperature) as avg_temperature,
        count(mean_temperature) as temperature_station_count,  

        avg(mean_dew_point) as avg_dew_point,
        avg(mean_sea_level_pressure) as avg_sea_level_pressure,
        avg(mean_station_pressure) as avg_station_pressure,
        avg(mean_visibility) as avg_visibility,
        avg(mean_wind_speed) as avg_wind_speed,
        max(max_wind_gust) as max_wind_gust, 
        avg(max_temperature) as avg_max_temperature,
        avg(min_temperature) as avg_min_temperature,
        sum(precipitation) / nullif(count(precipitation), 0) as avg_precipitation,
        max(snow_depth) as max_snow_depth, 

        logical_or(fog) as fog_any,
        logical_or(rain_drizzle) as rain_drizzle_any,
        logical_or(snow_ice_pellets) as snow_ice_pellets_any,
        logical_or(hail) as hail_any,
        logical_or(thunder) as thunder_any,
        logical_or(tornado_funnel_cloud) as tornado_funnel_cloud_any,

        countif(fog) / count(fog) as fog_station_ratio,
        countif(rain_drizzle) / count(rain_drizzle) as rain_drizzle_station_ratio,
        countif(snow_ice_pellets) / count(snow_ice_pellets) as snow_ice_pellets_station_ratio,
        countif(hail) / count(hail) as hail_station_ratio,
        countif(thunder) / count(thunder) as thunder_station_ratio,
        countif(tornado_funnel_cloud) / count(tornado_funnel_cloud) as tornado_funnel_cloud_station_ratio
    from source
    group by date
)    

select * from daily