with
    source as
        (select * from {{ source("noaa_gsod", "stations") }}),

    renamed as
        (select
            cast(usaf as string) as stn,
            cast(wban as string) as wban,
            concat(usaf, "_", wban) as stn_wban,
            cast(name as string) as station_name,
            cast(country as string) as station_country,
            cast(state as string) as station_state,
            cast(call as string) as station_call,
            cast(lat as float64) as latitude,
            cast(lon as float64) as longitude,
            st_geopoint(cast(lon as float64), cast(lat as float64)) as geo_point,
            cast(elev as string) as elevation,
            parse_date('%Y%m%d', cast(begin as string)) as start_date,
            parse_date('%Y%m%d', cast(`end` as string)) as end_date
        from 
            source)
        
select * from renamed
