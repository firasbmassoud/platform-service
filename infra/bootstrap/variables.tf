variable "project_name" {
  description = "Name of the service. Used for the ECR repository and resource naming."
  type        = string
  default     = "platform-service"
}

variable "aws_region" {
  description = "Region for the state bucket and container registry."
  type        = string
  default     = "eu-west-1"
}
