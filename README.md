
****** Serverless IoT Lakehouse on AWS  ******


**** Project Overview

In this project, I designed and implemented a serverless data lakehouse architecture on AWS using Terraform and Python.

The goal was to simulate a real-world IoT data platform capable of:

Ingesting raw data
Storing it in a scalable data lake
Transforming it into optimized formats
Enabling efficient SQL-based analytics

I focused on building a solution that is scalable, cost-efficient, and aligned with AWS best practices.


**** Architecture Design

I followed a serverless architecture approach, which means I avoided managing infrastructure (like EC2) and instead relied on fully managed AWS services.

The overall data flow is:

Data Ingestion → Amazon S3 (Raw) → ETL Processing → Curated Data → Parquet Optimization → Athena Queries
Why this design?
I chose Amazon S3 because it provides highly durable and scalable storage
I used AWS Glue to manage metadata and schemas
I used Amazon Athena to query data directly from S3 without provisioning databases
I used Terraform to automate infrastructure deployment

This combination allows building a modern data platform with minimal operational overhead.


**** Data Lakehouse Layers

To structure the data properly, I implemented a layered architecture.

🔹 Raw Layer

This layer stores the original data in JSON format.

Location: raw/iot_events/
Purpose: act as the source of truth
Data is stored as-is, without modification
🔹 Curated Layer (JSON)

In this layer, I clean and structure the data.

Location: curated/device_health/
I apply transformations and prepare the data for analysis
🔹 Optimized Layer (Parquet)

This is the most important layer for analytics.

Location: curated/device_health_parquet/
Format: Parquet (columnar)
Partitioning strategy:
device_type / year / month / day
Why Parquet?
Reduces storage size
Improves query performance
Minimizes Athena costs


===> ETL Pipeline

I implemented a Python-based ETL pipeline using Pandas.

The transformation flow is:

Raw JSON → Data Cleaning → Feature Engineering → Parquet Conversion → Partitioned Storage
Transformations I implemented:
Removed invalid or missing data
Added temperature_status (normal / critical)
Added battery_status (normal / low)
Calculated maintenance_risk based on multiple conditions

This step is important because it transforms raw data into business-ready insights.



====> Analytics with Athena



Once the data is stored in Parquet format, I use Athena to query it.

Example query:

SELECT device_id, temperature, battery_status
FROM iot_lakehouse_db.device_health_parquet
WHERE device_type = 'industrial_sensor'
AND year = 2026
AND month = '04';
Why Athena?
No infrastructure to manage
Pay-per-query model
Direct integration with S3


====> Infrastructure as Code

I used Terraform to provision all resources.

Resources created:
S3 bucket (data lake)
Glue database and tables
Athena workgroup
CloudWatch log group
Why Terraform?
Ensures reproducibility
Allows version control
Eliminates manual configuration
Makes the architecture portable


====> Security Considerations

Even though this is a serverless project, I considered security aspects:

S3 bucket is private by default
Access is controlled using IAM roles
Principle of least privilege is applied
The architecture can be extended with VPC endpoints for private access


====> Cost Optimization

I designed the solution to stay within AWS Free Tier as much as possible.

Key decisions:

Using serverless services (no idle cost)
Using Parquet to reduce scanned data
Partitioning to optimize Athena queries
Avoiding always-on compute resources


====> Scalability and Reliability

The architecture is highly scalable:

S3 can store unlimited data
Athena automatically scales with queries
No manual scaling required

For reliability:

S3 ensures high durability (multi-AZ)
Serverless services reduce operational risks


====> Networking (Future Extension)

Currently, the architecture does not use a VPC because all services are serverless.

However, I planned future improvements:

Deploy ETL inside a private subnet
Use VPC endpoints for secure S3 access
Add controlled network boundaries


====> Future Improvements

If I extend this project, I would add:

Apache Iceberg (ACID tables + time travel)
Real-time ingestion using Kinesis
Data Mesh architecture (multi-domain)
CI/CD pipeline for automation
Monitoring and alerting


====> What I learned

Through this project, I gained hands-on experience with:

Designing cloud-native architectures
Using Infrastructure as Code
Building ETL pipelines
Optimizing data storage and queries
Applying AWS best practices


=====> Conclusion

This project allowed me to build a complete serverless data platform from scratch.

It demonstrates how to combine:

Scalability
Cost efficiency
Simplicity
Automation

to create a modern data solution on AWS.
<img width="623" height="646" alt="image" src="https://github.com/user-attachments/assets/b9cdf660-e9f3-4fc9-b36d-57b24f997c01" />

