module "web_service" {
  source           = "../../modules/web_service"
  vpc_cidr         = "10.0.0.0/16"
  instance_type    = "t2.micro"
  desired_capacity = 3
}
