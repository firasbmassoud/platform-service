output "service_url" {
  description = "Public URL of the service."
  value       = "http://${module.alb.dns_name}"
}

output "cluster_name" {
  value = module.service.cluster_name
}
