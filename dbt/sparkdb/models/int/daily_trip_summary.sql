SELECT 
  to_date(tpep_pickup_datetime) AS trip_date,
  COUNT(*) AS daily_total_trips,
  SUM(passenger_count) AS daily_total_passengers,
  SUM(trip_distance) AS daily_total_distance,
  SUM(fare_amount) AS daily_total_fare,
  SUM(tip_amount) AS daily_total_tips,
  SUM(total_amount) AS daily_total_revenue
FROM {{ref("nyct_yellow_tripdata")}}
GROUP BY DATE(tpep_pickup_datetime);

