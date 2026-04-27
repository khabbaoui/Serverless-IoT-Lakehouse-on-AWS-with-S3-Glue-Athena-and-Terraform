🚀 Serverless IoT Lakehouse on AWS


📌 Overview

This project implements a serverless data lakehouse architecture on AWS using Terraform and Python.

It demonstrates how to design and deploy a scalable, cost-efficient, and cloud-native data platform that ingests, transforms, and analyzes IoT-like data.

Data Ingestion → Data Lake (S3) → ETL Processing → Curated Data (Parquet) → SQL Analytics (Athena)


🧠 Architecture Approach

The solution follows a serverless architecture pattern, eliminating the need for infrastructure management while ensuring scalability and cost efficiency.

Key Design Decisions
Amazon S3 is used as the data lake due to its durability and scalability
AWS Glue provides schema management and metadata catalog
Amazon Athena enables serverless SQL analytics
Terraform ensures reproducible and automated infrastructure deployment
Python ETL handles data transformation and business logic


🧱 Data Lakehouse Layers
🔹 Raw Layer
Stores incoming JSON data
Immutable and append-only
Used as the source of truth
🔹 Curated Layer
Cleaned and structured data
Business logic applied
🔹 Optimized Layer (Parquet)
Columnar format for performance
Partitioned by:
device_type
year
month
day


🔄 ETL Pipeline

The ETL pipeline transforms raw data into optimized analytical datasets:

Raw JSON → Data Cleaning → Business Logic → Parquet Conversion → Partitioned Storage
Transformations
Data validation
Temperature classification
Battery status detection
Maintenance risk scoring



📊 Analytics


Amazon Athena is used to query the data directly from S3:

SELECT device_id, temperature, battery_status
FROM iot_lakehouse_db.device_health_parquet
WHERE device_type = 'industrial_sensor'
AND year = 2026
AND month = '04';



⚙️ Infrastructure as Code


All infrastructure is provisioned using Terraform:

S3 data lake
Glue database and tables
Athena workgroup
CloudWatch logs

This ensures:

Reproducibility
Version control
Automated deployments


🔐 Security Considerations


S3 bucket is private by default
IAM roles follow least privilege principles
Data access is controlled through AWS policies
Architecture can be extended with VPC endpoints for private access


💰 Cost Optimization

The architecture is designed to minimize cost:

Fully serverless (no idle resources)
Pay-per-query model with Athena
Partitioning reduces data scanned
No always-on compute instances


📈 Scalability & Reliability

Amazon S3 provides virtually unlimited storage
Athena scales automatically with query demand
Serverless services ensure high availability
Data is durably stored across multiple AZs


🌐 Networking (Future Enhancement)

While not required for serverless services, the architecture can be extended with:

VPC with private subnets
S3 VPC endpoints
Secure data processing environments


🔮 Future Improvements


Apache Iceberg (ACID transactions & time travel)
Real-time ingestion using Kinesis
Data Mesh architecture
CI/CD pipeline for automated deployment
Advanced monitoring and alerting


💼 Resume Description

Built a serverless IoT data lakehouse on AWS using Terraform, S3, Glue, and Athena. Designed a multi-layer architecture, implemented ETL pipelines in Python to transform raw JSON into partitioned Parquet datasets, and enabled scalable, cost-efficient analytics.



🏁 Conclusion

This project demonstrates how to design a modern cloud-native data platform using AWS best practices, focusing on:

Scalability
Cost efficiency
Simplicity
Automation


## Architecture

```mermaid
flowchart LR
    subgraph IaC["Infrastructure as Code"]
        TF[Terraform]
    end

    subgraph AWS["AWS Serverless Lakehouse"]
        S3[(Amazon S3 Data Lake)]
        GLUE[AWS Glue Data Catalog]
        ATHENA[Amazon Athena]
        CW[CloudWatch Logs]
    end

    subgraph Layers["Data Lakehouse Layers"]
        RAW[Raw Zone<br/>JSON files]
        CURATED[Curated Zone<br/>Cleaned data]
        PARQUET[Optimized Zone<br/>Partitioned Parquet]
    end

    subgraph ETL["Python ETL Pipeline"]
        CLEAN[Data Cleaning]

        RULES[Business Rules]
        FORMAT[Parquet Conversion]
    end

    TF --> AWS

    S3 --> RAW
    RAW --> CLEAN
    CLEAN --> RULES
    RULES --> FORMAT
    FORMAT --> PARQUET

    PARQUET --> GLUE
    GLUE --> ATHENA
    ATHENA --> INSIGHTS[SQL Analytics]

    AWS --> CW
