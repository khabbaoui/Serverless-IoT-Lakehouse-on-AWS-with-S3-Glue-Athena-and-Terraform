#!/bin/bash
set -e

cd infrastructure
export BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd ..

python src/etl/raw_to_curated_parquet.py