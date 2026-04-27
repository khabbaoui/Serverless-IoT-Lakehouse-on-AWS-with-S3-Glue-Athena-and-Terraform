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
