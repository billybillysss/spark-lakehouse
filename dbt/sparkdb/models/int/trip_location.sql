-- Create date dimension table
SELECT DISTINCT
  PULocationID AS location_id,
  'pickup' AS location_type
FROM {{ref("nyct_yellow_tripdata")}}
UNION
SELECT DISTINCT
  DOLocationID AS location_id,
  'dropoff' AS location_type
FROM {{ref("nyct_yellow_tripdata")}};
