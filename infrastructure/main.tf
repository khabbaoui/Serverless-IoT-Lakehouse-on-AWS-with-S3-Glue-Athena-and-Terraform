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
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
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
data "archive_file" "lambda_validator_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/lambda/validator.py"
  output_path = "${path.module}/lambda_validator.zip"
}

resource "aws_iam_role" "lambda_validator_role" {
  name = "${var.project_name}-lambda-validator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_validator_policy" {
  name = "${var.project_name}-lambda-validator-policy"
  role = aws_iam_role.lambda_validator_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.lakehouse.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "raw_validator" {
  function_name = "${var.project_name}-raw-validator"
  role          = aws_iam_role.lambda_validator_role.arn
  handler       = "validator.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_validator_zip.output_path
  source_code_hash = data.archive_file.lambda_validator_zip.output_base64sha256

  timeout = 30
}

resource "aws_lambda_permission" "allow_s3_to_call_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.raw_validator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lakehouse.arn
}

resource "aws_s3_bucket_notification" "raw_upload_notification" {
  bucket = aws_s3_bucket.lakehouse.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.raw_validator.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw/iot_events/"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_s3_to_call_lambda]
}

resource "aws_s3_bucket_public_access_block" "lakehouse_block_public_access" {
  bucket = aws_s3_bucket.lakehouse.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "lakehouse_versioning" {
  bucket = aws_s3_bucket.lakehouse.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lakehouse_encryption" {
  bucket = aws_s3_bucket.lakehouse.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}