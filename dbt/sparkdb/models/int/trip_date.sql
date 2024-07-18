-- Create date dimension table
SELECT 
  DATE(tpep_pickup_datetime) AS date,
  EXTRACT(year FROM tpep_pickup_datetime) AS year,
  EXTRACT(month FROM tpep_pickup_datetime) AS month,
  EXTRACT(day FROM tpep_pickup_datetime) AS day,
  EXTRACT(dayofweek FROM tpep_pickup_datetime) AS day_of_week,
  EXTRACT(week FROM tpep_pickup_datetime) AS week
FROM {{ref("nyct_yellow_tripdata")}}
GROUP BY DATE(tpep_pickup_datetime);




