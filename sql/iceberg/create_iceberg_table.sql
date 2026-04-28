CREATE TABLE iot_lakehouse_db.device_health_iceberg (
  device_id string,
  temperature double,
  vibration double,
  battery_level int,
  temperature_status string,
  battery_status string,
  maintenance_risk string,
  event_timestamp timestamp
)
LOCATION 's3://serverless-iot-lakehouse-7046eef4/iceberg/device_health/'
TBLPROPERTIES (
  'table_type'='ICEBERG',
  'format'='PARQUET'
);