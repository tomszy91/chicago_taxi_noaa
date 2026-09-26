with source as (
    select * from {{ source("chicago_taxi_trips", "taxi_trips") }}
),

renamed as (
    select
        cast(unique_key as string) as unique_key,
        cast(taxi_id as string) as taxi_id,
        cast(trip_start_timestamp as timestamp) as trip_start_timestamp,
        cast(trip_end_timestamp as timestamp) as trip_end_timestamp,
        cast(trip_seconds as int64) as trip_seconds,
        cast(trip_miles as float64) as trip_miles,
        cast(pickup_census_tract as int64) as pickup_census_tract,
        cast(dropoff_census_tract as int64) as dropoff_census_tract,
        cast(pickup_community_area as int64) as pickup_community_area,
        cast(dropoff_community_area as int64) as dropoff_community_area,
        cast(fare as float64) as fare,
        cast(tips as float64) as tips,
        cast(tolls as float64) as tolls,
        cast(extras as float64) as extras,
        cast(trip_total as float64) as trip_total,
        cast(payment_type as string) as payment_type,
        cast(company as string) as company,
        cast(pickup_latitude as float64) as pickup_latitude,
        cast(pickup_longitude as float64) as pickup_longitude,
        cast(pickup_location as string) as pickup_location,
        cast(dropoff_latitude as float64) as dropoff_latitude,
        cast(dropoff_longitude as float64) as dropoff_longitude,
        cast(dropoff_location as string) as dropoff_location
    from source
)

select * from renamed
