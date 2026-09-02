output "state_bucket_name" {
  description = "Plug this into environments/production/backend.hcl as `bucket`."
  value       = aws_s3_bucket.state.id
}
