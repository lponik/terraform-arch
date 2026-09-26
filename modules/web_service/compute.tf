resource "aws_launch_template" "web" {
  name = "terraform-floci-web"

  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y nginx
    systemctl enable nginx
    systemctl start nginx

    echo "Hello from Terraform + Floci (v2)" > /usr/share/nginx/html/index.html
  EOF
  )

  tags = {
    Name = "terraform-floci-web-template"
  }
}

resource "aws_autoscaling_group" "web" {
  name = "terraform-floci-asg"
  lifecycle {
    ignore_changes = [desired_capacity]
  }

  min_size         = 3
  max_size         = 4
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }
  health_check_type         = "ELB"
  health_check_grace_period = 300

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 70
      instance_warmup        = 300
    }
  }
}


