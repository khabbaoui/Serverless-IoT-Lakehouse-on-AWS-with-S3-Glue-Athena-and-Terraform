UPDATE iot_lakehouse_db.device_health_iceberg
SET battery_level = 55,
    battery_status = 'normal',
    maintenance_risk = 'medium'
WHERE device_id = 'machine_01';