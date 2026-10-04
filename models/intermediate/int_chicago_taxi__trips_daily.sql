with
source as (
    select
        trip_start_timestamp,
        trip_seconds,
        trip_miles_corrected,
        trip_miles_was_reconstructed,
        trip_total
    from {{ ref("int_chicago_taxi__trips_cleaned")}}
),
grouped as (
    select
        date(trip_start_timestamp) as trip_date,
        count(*) as total_trips,
        avg(trip_seconds) as avg_trip_seconds,
        sum(trip_miles_corrected) as sum_trip_miles,
        avg(trip_miles_corrected) as avg_trip_miles,
        sum(case when
            trip_miles_was_reconstructed = true then trip_miles_corrected else 0 end) as sum_trip_miles_reconstructed,
        sum(case when
            trip_miles_was_reconstructed = false then trip_miles_corrected else 0 end) as sum_trip_miles_not_reconstructed,          
        countif(trip_miles_was_reconstructed) as total_reconstructed_trips,
        countif(not trip_miles_was_reconstructed) as total_not_reconstructed_trips,
        avg(trip_total) as avg_trip_total,
        sum(trip_total) as sum_trip_total
    from source         
    group by
        trip_date
)

select * from grouped
