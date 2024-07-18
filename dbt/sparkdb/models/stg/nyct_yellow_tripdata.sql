-- Create cleaned table
SELECT
  yellow_trip_key,
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  PULocationID,
  DOLocationID,
  fare_amount,
  tip_amount,
  total_amount
FROM per.nyct_yellow_tripdata
WHERE tpep_pickup_datetime IS NOT NULL
  AND tpep_dropoff_datetime IS NOT NULL
  AND passenger_count IS NOT NULL
  AND trip_distance IS NOT NULL
GROUP BY 
  yellow_trip_key,
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  PULocationID,
  DOLocationID,
  fare_amount,
  tip_amount,
  total_amount;