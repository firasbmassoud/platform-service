variable "project_name" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC the load balancer and target group live in."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets to place the load balancer in. At least two AZs."
  type        = list(string)
}

variable "container_port" {
  description = "Port the application listens on."
  type        = number
}

variable "health_check_path" {
  description = "Path the target group polls."
  type        = string
}
