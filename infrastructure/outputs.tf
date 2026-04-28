output "s3_bucket_name" {
  value = aws_s3_bucket.lakehouse.bucket
}

output "glue_database_name" {
  value = aws_glue_catalog_database.lakehouse_db.name
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.lakehouse_workgroup.name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.lakehouse_logs.name
}
output "athena_results_location" {
  value = "s3://${aws_s3_bucket.lakehouse.bucket}/athena-results/"
}