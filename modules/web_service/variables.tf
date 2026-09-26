variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "desired_capacity" {
  default = 3
}

variable "ami_id" {
  description = "AMI ID used by the EC2 launch template"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}