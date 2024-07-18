SELECT DISTINCT
  VendorID AS vendor_id,
  CASE 
    WHEN VendorID = 1 THEN 'Creative Mobile Technologies'
    WHEN VendorID = 2 THEN 'VeriFone Inc.'
    ELSE 'Unknown'
  END AS vendor_name
FROM {{ ref("nyct_yellow_tripdata") }};
