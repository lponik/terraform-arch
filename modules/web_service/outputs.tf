output "vpc_id" {
  value = aws_vpc.lab.id
}

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}