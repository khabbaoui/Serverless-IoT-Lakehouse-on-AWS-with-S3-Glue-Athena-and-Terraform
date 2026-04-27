variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "project_name" {
  type    = string
  default = "serverless-iot-lakehouse"
}

variable "glue_database_name" {
  type    = string
  default = "iot_lakehouse_db"
}

variable "athena_workgroup_name" {
  type    = string
  default = "iot_lakehouse_workgroup"
}