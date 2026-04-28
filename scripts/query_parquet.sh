#!/bin/bash
set -e

cd infrastructure
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd ..

aws athena start-query-execution \
  --query-string "SELECT * FROM iot_lakehouse_db.device_health_parquet LIMIT 10;" \
  --work-group iot_lakehouse_workgroup \
  --result-configuration OutputLocation=s3://$BUCKET_NAME/athena-results/