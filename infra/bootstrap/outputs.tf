output "state_bucket" {
  description = "Bucket the main stack stores its Terraform state in."
  value       = aws_s3_bucket.state.id
}

output "ecr_repository_url" {
  description = "Registry the deploy script pushes images to."
  value       = aws_ecr_repository.app.repository_url
}
