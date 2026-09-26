output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = module.web_service.alb_dns_name
}