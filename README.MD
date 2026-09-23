# Terraform + Floci Resilient Web Service Lab

This project is a Terraform infrastructure lab that models a resilient AWS-style web service locally with Floci.

It was built to practice cloud infrastructure patterns that show up in real environments: network isolation, load balancing, autoscaling, health checks, IAM roles, private administrative access, and controlled instance updates. The project runs against a local AWS-compatible emulator, so it can be developed and tested without creating real AWS resources or incurring cloud costs.

A real AWS deployment and validation pass is planned for the future.

## What This Project Does

The project defines a reusable Terraform module called `web_service` and uses it from the `environments/floci` environment.

In plain terms, it creates a small web application environment where traffic comes in through a load balancer, the application servers stay private, and Terraform manages the supporting infrastructure.

At a high level, it creates:

- A VPC using the `10.0.0.0/16` CIDR range
- Two public subnets
- Two private subnets
- An internet gateway and public routing
- A public Application Load Balancer listening on HTTP port 80
- An HTTP target group
- An Auto Scaling Group of private EC2 instances
- A launch template for the web instances
- IAM permissions and an instance profile for EC2
- SSM access without SSH
- VPC interface endpoints for `ssm` and `ssmmessages`
- CloudWatch CPU alarms
- Scaling policies
- Rolling instance refresh behavior

The web instances are intended to run nginx and serve a simple page that says:

```text
Hello from Terraform + Floci (v2)
```

## Key Design Choices

The goal of this project is not just to create a server. It is meant to show how several AWS infrastructure pieces work together in a safer, more realistic layout.

The load balancer is public, but the EC2 instances are private. Internet traffic reaches the application through the Application Load Balancer, and the instances only accept HTTP traffic from the load balancer security group.

There is no direct SSH access to the instances. The launch template does not use a key pair, and the security groups do not open port 22. Administrative access is designed around AWS Systems Manager instead, using an EC2 role with `AmazonSSMManagedInstanceCore` and private VPC endpoints for SSM communication.

This keeps the application tier away from direct internet access while still allowing a realistic management path.

## Traffic Flow

Traffic follows this path:

1. A user sends an HTTP request from the internet.
2. The request reaches the public Application Load Balancer on port 80.
3. The ALB forwards the request to the target group.
4. The target group sends traffic to healthy EC2 instances in the Auto Scaling Group.
5. The EC2 instances run in private subnets and are not directly exposed to the internet.

The EC2 security group only allows inbound HTTP from the ALB security group.

## Resilience and Scaling

The Auto Scaling Group is configured with:

- Minimum capacity: `3`
- Desired capacity: `3`
- Maximum capacity: `4`
- ELB health checks
- 300-second health check grace period

The target group checks instance health over HTTP at `/`.

CloudWatch CPU alarms and scaling policies are included to model how the service would respond to changing load. Terraform also uses launch template versioning and rolling instance refresh so that instance changes can be rolled out gradually instead of replacing everything at once.

The rolling instance refresh is configured with:

- Minimum healthy percentage: `70%`
- Instance warmup: `300` seconds

This means Terraform can replace instances in a controlled way while keeping enough capacity available during the update.

## Terraform Structure

The project is organized around a reusable module:

```text
environments/floci
modules/web_service
```

The `environments/floci` environment configures Terraform to use the AWS provider against Floci at:

```text
http://localhost:4566
```

The provider uses dummy credentials and disables AWS account and credential validation because the target is a local emulator, not real AWS.

The `web_service` module contains the main infrastructure resources, including networking, security groups, load balancing, compute, IAM, SSM endpoints, CloudWatch alarms, scaling policies, and outputs.

Terraform state is local for this lab. The project also uses moved blocks from a previous module refactor so Terraform can understand that resources were reorganized without treating them as brand-new infrastructure.

## Desired Capacity Ownership

The Auto Scaling Group uses `ignore_changes` on `desired_capacity`.

That is intentional. Terraform creates the ASG with a desired capacity of `3`, but after creation, scaling policies may adjust desired capacity in response to load. Ignoring later changes to `desired_capacity` prevents Terraform from fighting the autoscaling system and forcing the value back during every apply.

In other words, Terraform owns the ASG structure, while autoscaling is allowed to own day-to-day capacity changes.

## Testing Performed

The project has been tested locally with Floci for Terraform behavior and infrastructure lifecycle scenarios, including:

- Creating the VPC, subnets, load balancer, target group, launch template, Auto Scaling Group, IAM, SSM endpoints, CloudWatch alarms, and scaling policies
- Refactoring resources into the reusable `web_service` module using moved blocks
- Detecting drift
- Replacing Auto Scaling Group instances
- Rolling instance refresh behavior
- Launch template version changes
- Confirming that desired capacity changes are not overwritten by Terraform because of `ignore_changes`

These tests are useful for validating Terraform structure and lifecycle behavior in a local lab environment.

## Current Limitations

This project currently runs against Floci, not a live AWS account.

That means it is best understood as a local infrastructure simulation and Terraform practice environment. It can validate important IaC behavior, such as resource relationships, module structure, drift detection, launch template changes, and rolling updates.

However, Floci does not fully prove every real AWS behavior. Some cloud-service details still need to be validated in AWS, such as real load balancer behavior, real EC2 bootstrapping, real SSM session connectivity, real CloudWatch alarm evaluation, real target group health checks, and production-grade networking behavior.

## Future Plans

Planned next steps include:

- Deploying the same architecture to a real AWS account
- Validating ALB, target group, ASG, SSM, and CloudWatch behavior against real AWS services
- Adding a clean architecture diagram
- Expanding the README with screenshots or command output from the real deployment
- Adding notes about costs, cleanup, and operational considerations for AWS

## Running Locally

This project is designed to run with Floci listening locally on port `4566`.

From the Floci environment directory:

```bash
cd environments/floci
terraform init
terraform plan
terraform apply
```

To remove the local infrastructure:

```bash
terraform destroy
```

Because this environment points Terraform at Floci with dummy AWS credentials, it is intended for local testing. Before using the module against real AWS, the provider configuration and validation settings should be reviewed carefully.

## Summary

This repository demonstrates a practical AWS-style web service architecture using Terraform and Floci. It focuses on infrastructure fundamentals that matter in real environments: private instances, public load balancing, restricted administrative access, autoscaling, health checks, IAM roles, local Terraform state, module organization, and controlled instance updates.

It is currently a local lab, not a production deployment. The next major milestone is validating the design in a real AWS account.
