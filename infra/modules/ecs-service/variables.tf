variable "project_name" {
  description = "Prefix for resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC the tasks run in."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets to place tasks in."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group of the load balancer, allowed to reach the tasks."
  type        = string
}

variable "target_group_arn" {
  description = "Target group tasks register with."
  type        = string
}

variable "image" {
  description = "Full image URI including tag."
  type        = string
}

variable "container_port" {
  description = "Port the application listens on."
  type        = number
}

variable "desired_count" {
  description = "Number of tasks to run."
  type        = number
}

variable "cpu" {
  description = "Task CPU units. 512 = 0.5 vCPU."
  type        = number
}

variable "memory" {
  description = "Task memory in MiB."
  type        = number
}
