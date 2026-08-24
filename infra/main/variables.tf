variable "project_name" {
  description = "Name of the service. Must match the ECR repository created by the bootstrap stack."
  type        = string
  default     = "platform-service"
}

variable "aws_region" {
  description = "Region to deploy into."
  type        = string
  default     = "eu-west-1"
}

variable "image_tag" {
  description = "Image tag to deploy. The Makefile sets this to the current git short SHA."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Avoids 172.31.0.0/16 so it does not clash with the default VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Availability zones to spread across. Two is the minimum an ALB accepts."
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Port the application listens on."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Number of tasks. Two so a single task failure does not take the service down."
  type        = number
  default     = 2
}

variable "task_cpu" {
  description = "Task CPU units. 512 = 0.5 vCPU."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Task memory in MiB."
  type        = number
  default     = 1024
}
