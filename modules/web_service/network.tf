resource "aws_vpc" "lab" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "terraform-floci-lab"
    Environment = "local"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.lab.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "terraform-floci-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name = "terraform-floci-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb" {
  name        = "terraform-floci-alb-sg"
  description = "Allow inbound HTTP traffic to the ALB"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-floci-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "terraform-floci-ec2-sg"
  description = "Allow HTTP only from the ALB"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-floci-ec2-sg"
  }
}


resource "aws_security_group" "ssm_endpoint" {
  name        = "terraform-floci-ssm-sg"
  description = "Allow inbound HTTPS traffic from EC2"
  vpc_id      = aws_vpc.lab.id

  ingress{
    description = "HTTPS from EC2 SG"
    security_groups = [aws_security_group.ec2.id]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.lab.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_endpoint.id,
  ]

  private_dns_enabled = true
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.lab.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ssm_endpoint.id,
  ]

  private_dns_enabled = true
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}
