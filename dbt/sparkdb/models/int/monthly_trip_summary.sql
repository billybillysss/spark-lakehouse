SELECT
  month(tpep_pickup_datetime) AS trip_month,
  COUNT(*) AS monthly_total_trips,
  SUM(passenger_count) AS monthly_total_passengers,
  SUM(trip_distance) AS monthly_total_distance,
  SUM(fare_amount) AS monthly_total_fare,
  SUM(tip_amount) AS monthly_total_tips,
  SUM(total_amount) AS monthly_total_revenue
FROM {{ref("nyct_yellow_tripdata")}}
GROUP BY month(tpep_pickup_datetime);

