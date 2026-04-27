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