output "state_bucket_name" {
  description = "Plug this into environments/production/backend.hcl as `bucket`."
  value       = aws_s3_bucket.state.id
}

output "state_lock_table_name" {
  description = "Plug this into environments/production/backend.hcl as `dynamodb_table`."
  value       = aws_dynamodb_table.lock.name
}
