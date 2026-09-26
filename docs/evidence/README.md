# Deployment Evidence

These sanitized screenshots document the temporary deployment against real AWS services.

## Application and Load Balancing

![Figure 1 — Public Application Load Balancer successfully serving the Nginx test page.](01-alb-response.png)

![Figure 2 — Application Load Balancer target group reporting three healthy EC2 targets.](02-healthy-targets.png)

![Figure 3 — Target group distributing three healthy EC2 targets across two Availability Zones.](03-target-distribution.png)

## Compute and Networking

![Figure 4 — Private EC2 instances running without public IPv4 addresses.](04-private-instances.png)

![Figure 5 — Separate public and private route tables, with no NAT Gateway required.](05-route-tables.png)

![Figure 6 — Public route table directing internet-bound traffic through an Internet Gateway.](06-public-route.png)

![Figure 7 — S3 gateway and Systems Manager interface endpoints providing private AWS service access.](07-vpc-endpoints.png)

![Figure 8 — Layered security groups restricting traffic between the ALB, EC2 instances, and VPC endpoints.](08-security-groups.png)

## Private Administration and Configuration Validation

![Figure 9 — Systems Manager Fleet Manager reporting three running, online managed nodes.](09-fleet-manager.png)

![Figure 10 — AWS Systems Manager providing administrative access without SSH or public IP addresses.](10-session-manager.png)

![Figure 11 — Terraform confirming that the deployed infrastructure matches the declared configuration.](11-terraform-plan.png)


