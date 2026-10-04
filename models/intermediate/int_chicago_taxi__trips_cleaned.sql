{{ config(
    partition_by={
        "field": "trip_start_timestamp",
        "data_type": "timestamp",
        "granularity": "year"
    }
) }}

with
    source as (
        select
            unique_key,
            taxi_id,
            trip_start_timestamp,
            trip_end_timestamp,
            trip_seconds,
            trip_miles,
            fare,
            tips,
            tolls,
            extras,
            trip_total,
            payment_type,
            company,
            pickup_longitude,
            pickup_latitude,
            dropoff_longitude,
            dropoff_latitude
        from {{ ref("stg_chicago_taxi__trips") }}
    ),

    corrected as (
        select
            unique_key,
            taxi_id,
            trip_start_timestamp,
            trip_end_timestamp,
            trip_seconds,
            case
                when trip_miles > 0
                then trip_miles
                when
                    trip_miles = 0
                    and pickup_longitude is not null
                    and pickup_latitude is not null
                    and dropoff_longitude is not null
                    and dropoff_latitude is not null
                then
                    st_distance(
                        st_geogpoint(pickup_longitude, pickup_latitude),
                        st_geogpoint(dropoff_longitude, dropoff_latitude)
                    )
                    / 1609.34
                else null
            end as trip_miles_corrected,
            case
                when trip_miles = 0
                    and pickup_longitude is not null
                    and pickup_latitude is not null
                    and dropoff_longitude is not null
                    and dropoff_latitude is not null
                then true else false end as trip_miles_was_reconstructed,
            fare,
            tips,
            tolls,
            extras,
            trip_total,
            payment_type,
            company,
            st_geogpoint(pickup_longitude, pickup_latitude) as pickup_location,
            st_geogpoint(dropoff_longitude, dropoff_latitude) as dropoff_location
        from source
    ),

    cleaned as (
        select *
        from corrected
        where
            trip_total is not null
            and trip_miles_corrected is not null
            and trip_seconds is not null
            and trip_seconds != 0
    )

select *
from cleaned
