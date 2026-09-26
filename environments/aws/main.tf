data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "web_service" {
  source = "../../modules/web_service"

  ami_id     = data.aws_ssm_parameter.al2023_ami.value
  aws_region = var.aws_region
}