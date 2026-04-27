# Serverless-IoT-Lakehouse-on-AWS-using-Data-Mesh-and-Apache-Iceberg
Serverless IoT Lakehouse on AWS

A modern cloud-native data platform built with AWS serverless services, Terraform, and Python ETL.

**** Overview

This project implements a serverless data lakehouse architecture on AWS.

It demonstrates how to:

Ingest IoT-like data
Store it in a scalable data lake
Transform it using ETL
Query it efficiently with SQL
**** Architecture
Terraform (IaC)
        ↓
Amazon S3 (Data Lake)
   ├── raw/
   ├── curated/
   ├── curated (Parquet partitioned)
   └── athena-results/

AWS Glue (Data Catalog)
   ├── iot_raw
   ├── device_health
   └── device_health_parquet

Amazon Athena (Query Engine)
        ↓
SQL Analytics

Python ETL
        ↓
Raw JSON → Cleaned → Parquet
⚙️ Tech Stack
Terraform — Infrastructure as Code
Amazon S3 — Data Lake
AWS Glue — Data Catalog
Amazon Athena — Query Engine
Python (Pandas, PyArrow) — ETL
GitHub Codespaces — Development Environment
***** Data Layers
🔹 Raw Layer
Format: JSON
Path: raw/iot_events/
Table: iot_raw
🔹 Curated Layer (JSON)
Cleaned data
Path: curated/device_health/
Table: device_health
🔹 Curated Layer (Parquet) ⭐
Columnar format
Optimized for analytics
Partitioned by:
device_type / year / month / day
Table: device_health_parquet
***** ETL Pipeline
Raw JSON
   ↓
Python ETL (Pandas)
   ↓
Data Cleaning + Business Logic
   ↓
Partitioned Parquet
   ↓
S3 Curated Layer
Transformations
Data validation
Temperature classification
Battery status detection
Maintenance risk scoring
***** Example Query
SELECT device_id, temperature, battery_status
FROM iot_lakehouse_db.device_health_parquet
WHERE device_type = 'industrial_sensor'
AND year = 2026
AND month = '04'
AND day = '27';
***** Getting Started
1. Clone the repository
git clone https://github.com/<your-username>/Serverless-IoT-Lakehouse-on-AWS.git
cd Serverless-IoT-Lakehouse-on-AWS
2. Deploy infrastructure
cd infrastructure
terraform init
terraform plan
terraform apply
3. Run ETL
python src/etl/raw_to_curated_parquet.py
4. Query data
aws athena start-query-execution \
  --query-string "SELECT * FROM iot_lakehouse_db.device_health_parquet LIMIT 10;" \
  --work-group iot_lakehouse_workgroup \
  --result-configuration OutputLocation=s3://<your-bucket>/athena-results/
***** Cost Control

This project is optimized for AWS Free Tier:

Serverless architecture
Small data volumes
No always-on compute

***** Note: Real-time streaming (Kinesis) is intentionally disabled to avoid costs.

***** Key Learnings
Data Lakehouse architecture
Infrastructure as Code (Terraform)
ETL pipelines with Python
Parquet optimization and partitioning
Serverless analytics with Athena
Metadata management with Glue
***** Resume Description

Built a serverless IoT data lakehouse on AWS using Terraform, S3, Glue, and Athena. Implemented ETL pipelines in Python to transform raw JSON data into partitioned Parquet datasets, enabling efficient analytical queries in a scalable and cost-efficient architecture.

***** Future Improvements
Apache Iceberg tables (ACID + time travel)
Real-time ingestion (Kinesis)
Data Mesh architecture
VPC and security hardening
CI/CD pipeline
🏁 Conclusion

This project demonstrates how to build a modern, scalable, and cost-efficient data platform using AWS serverless services and best practices in data engineering.
