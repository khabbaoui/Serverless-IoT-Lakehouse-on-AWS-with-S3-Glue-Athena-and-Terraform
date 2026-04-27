terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "lakehouse" {
  bucket = "${var.project_name}-${random_id.suffix.hex}"
}

resource "aws_s3_object" "folders" {
  for_each = toset([
    "raw/",
    "curated/",
    "athena-results/",
    "logs/"
  ])

  bucket = aws_s3_bucket.lakehouse.id
  key    = each.value
}

resource "aws_glue_catalog_database" "lakehouse_db" {
  name = var.glue_database_name
}

resource "aws_athena_workgroup" "lakehouse_workgroup" {
  name = var.athena_workgroup_name

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.lakehouse.bucket}/athena-results/"
    }
  }
}

resource "aws_cloudwatch_log_group" "lakehouse_logs" {
  name              = "/aws/lakehouse/${var.project_name}"
  retention_in_days = 7
}
resource "aws_s3_object" "sample_raw_data" {
  bucket = aws_s3_bucket.lakehouse.id
  key    = "raw/iot_events/sample.json"

  content = jsonencode({
    device_id     = "machine_01"
    temperature   = 85.5
    vibration     = 0.72
    battery_level = 18
    timestamp     = "2026-04-27T20:00:00Z"
  })
}

resource "aws_glue_catalog_table" "iot_raw" {
  name          = "iot_raw"
  database_name = aws_glue_catalog_database.lakehouse_db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.lakehouse.bucket}/raw/iot_events/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "json-serde"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "device_id"
      type = "string"
    }

    columns {
      name = "temperature"
      type = "double"
    }

    columns {
      name = "vibration"
      type = "double"
    }

    columns {
      name = "battery_level"
      type = "int"
    }

    columns {
      name = "timestamp"
      type = "string"
    }
  }
}
resource "aws_s3_object" "sample_curated_data" {
  bucket = aws_s3_bucket.lakehouse.id
  key    = "curated/device_health/sample.json"

  content = jsonencode({
    device_id     = "machine_01"
    temperature   = 85.5
    vibration     = 0.72
    battery_level = 18
    timestamp     = "2026-04-27T20:00:00Z"
  })
}
resource "aws_glue_catalog_table" "device_health" {
  name          = "device_health"
  database_name = aws_glue_catalog_database.lakehouse_db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.lakehouse.bucket}/curated/device_health/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "json-serde"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "device_id"
      type = "string"
    }

    columns {
      name = "temperature"
      type = "double"
    }

    columns {
      name = "vibration"
      type = "double"
    }

    columns {
      name = "battery_level"
      type = "int"
    }

    columns {
      name = "timestamp"
      type = "string"
    }
  }
}
resource "aws_glue_catalog_table" "device_health_parquet" {
  name          = "device_health_parquet"
  database_name = aws_glue_catalog_database.lakehouse_db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "parquet"
  }
  partition_keys {
    name = "device_type"
    type = "string"
  }

  partition_keys {
    name = "year"
    type = "int"
  }

  partition_keys {
    name = "month"
    type = "string"
  }

  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.lakehouse.bucket}/curated/device_health_parquet/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "device_id"
      type = "string"
    }

    columns {
      name = "temperature"
      type = "double"
    }

    columns {
      name = "vibration"
      type = "double"
    }

    columns {
      name = "battery_level"
      type = "int"
    }

    columns {
      name = "timestamp"
      type = "string"
    }

    columns {
      name = "temperature_status"
      type = "string"
    }

    columns {
      name = "battery_status"
      type = "string"
    }
  }
}