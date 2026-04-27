#!/bin/bash
set -e

aws athena start-query-execution \
  --query-string "SELECT * FROM iot_lakehouse_db.device_health_parquet LIMIT 10;" \
  --work-group iot_lakehouse_workgroup \
  --result-configuration OutputLocation=s3://serverless-iot-lakehouse-7046eef4/athena-results/