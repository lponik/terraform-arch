# Terraform + Floci Resilient Web Service Lab

This project uses Terraform and Floci to model a resilient AWS web service in a local environment. It was built to practice infrastructure patterns used in production, including network isolation, load balancing, autoscaling, health checks, IAM, private administrative access, and rolling updates, without creating billable AWS resources.

The current version is a local infrastructure lab. Deployment and validation in a real AWS account are planned.

## What It Builds

The reusable `web_service` module creates:

- A VPC using `10.0.0.0/16`
- Two public and two private subnets
- An internet gateway and public routing
- A public Application Load Balancer on port 80
- An HTTP target group with health checks at `/`
- An Auto Scaling Group of EC2 instances in the private subnets
- A launch template and IAM instance profile
- SSM access through `ssm` and `ssmmessages` interface endpoints
- CloudWatch CPU alarms and scaling policies
- Rolling instance refresh behavior

The instances install nginx and serve a simple test page:

```text
Hello from Terraform + Floci (v2)
```

## How It Works

Internet traffic reaches the public Application Load Balancer, which forwards requests to healthy instances in the Auto Scaling Group. The instances remain in private subnets and accept HTTP traffic only from the ALB security group, so they are not directly exposed to the internet.

Administrative access is designed around AWS Systems Manager rather than SSH. There is no key pair or inbound rule for port 22. The instances use an IAM role with `AmazonSSMManagedInstanceCore`, while private VPC endpoints provide access to `ssm` and `ssmmessages`.

## Resilience and Scaling

The Auto Scaling Group is configured with:

- Minimum capacity: `3`
- Desired capacity: `3`
- Maximum capacity: `4`
- ELB health checks with a 300-second grace period

CloudWatch CPU alarms connect to scaling policies that model how capacity can adjust as load changes.

Launch template versioning works with rolling instance refresh to replace instances gradually after configuration changes. During a refresh, at least `70%` of instances must remain healthy, and new instances receive a 300-second warmup period.

Terraform ignores later changes to `desired_capacity`. It sets the initial value, then leaves routine capacity adjustments to the scaling policies instead of resetting them during future applies.

## Terraform Structure

```text
environments/floci
modules/web_service
```

`environments/floci` configures the AWS provider to use Floci at `http://localhost:4566`. It uses dummy credentials and disables AWS account and credential validation because no live AWS account is involved.

`modules/web_service` contains the networking, security, load balancing, compute, IAM, SSM, monitoring, scaling, and output definitions.

State is stored locally for this lab. Terraform `moved` blocks preserve resource identity after the infrastructure was refactored into the module, preventing unchanged resources from being treated as new.

## Testing Performed

Local testing with Floci covered:

- Creating the complete infrastructure stack
- Refactoring resources into the reusable module
- Detecting infrastructure drift
- Replacing Auto Scaling Group instances
- Updating launch template versions
- Triggering rolling instance refresh behavior
- Confirming that Terraform does not overwrite autoscaling changes to desired capacity

## Limitations

Floci is useful for testing Terraform structure, resource relationships, drift detection, and lifecycle behavior, but it does not reproduce every detail of AWS.

A real AWS deployment is still needed to validate ALB routing, EC2 bootstrapping, SSM session connectivity, CloudWatch alarm evaluation, target group health checks, and production networking behavior. This repository should therefore be viewed as a local lab, not a production deployment.

## Future Plans

- Deploy and validate the architecture in a real AWS account
- Add an architecture diagram
- Include evidence from the live deployment, such as screenshots or command output
- Document AWS costs, cleanup, and operational considerations

## Running Locally

With Floci available on port `4566`, run the following from the repository:

```bash
cd environments/floci
terraform init
terraform plan
terraform apply
```

To remove the local resources:

```bash
terraform destroy
```

The current provider configuration is intended for local testing. Review its endpoint, credentials, and validation settings before targeting a real AWS account.