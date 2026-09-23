moved {
  from = aws_vpc.lab
  to   = module.web_service.aws_vpc.lab
}

moved {
  from = aws_autoscaling_attachment.web
  to   = module.web_service.aws_autoscaling_attachment.web
}

moved {
  from = aws_autoscaling_group.web
  to   = module.web_service.aws_autoscaling_group.web
}

moved {
  from = aws_autoscaling_policy.scale_in
  to   = module.web_service.aws_autoscaling_policy.scale_in
}

moved {
  from = aws_autoscaling_policy.scale_out
  to   = module.web_service.aws_autoscaling_policy.scale_out
}

moved {
  from = aws_cloudwatch_metric_alarm.high_cpu
  to   = module.web_service.aws_cloudwatch_metric_alarm.high_cpu
}

moved {
  from = aws_cloudwatch_metric_alarm.low_cpu
  to   = module.web_service.aws_cloudwatch_metric_alarm.low_cpu
}

moved {
  from = aws_iam_instance_profile.web
  to   = module.web_service.aws_iam_instance_profile.web
}

moved {
  from = aws_iam_role.ec2
  to   = module.web_service.aws_iam_role.ec2
}

moved {
  from = aws_iam_role_policy.ec2_monitoring
  to   = module.web_service.aws_iam_role_policy.ec2_monitoring
}

moved {
  from = aws_internet_gateway.lab
  to   = module.web_service.aws_internet_gateway.lab
}

moved {
  from = aws_launch_template.web
  to   = module.web_service.aws_launch_template.web
}

moved {
  from = aws_lb.web
  to   = module.web_service.aws_lb.web
}

moved {
  from = aws_lb_listener.web
  to   = module.web_service.aws_lb_listener.web
}

moved {
  from = aws_lb_target_group.web
  to   = module.web_service.aws_lb_target_group.web
}

moved {
  from = aws_route_table.public
  to   = module.web_service.aws_route_table.public
}

moved {
  from = aws_route_table_association.public_a
  to   = module.web_service.aws_route_table_association.public_a
}

moved {
  from = aws_route_table_association.public_b
  to   = module.web_service.aws_route_table_association.public_b
}

moved {
  from = aws_security_group.alb
  to   = module.web_service.aws_security_group.alb
}

moved {
  from = aws_security_group.ec2
  to   = module.web_service.aws_security_group.ec2
}

moved {
  from = aws_subnet.private_a
  to   = module.web_service.aws_subnet.private_a
}

moved {
  from = aws_subnet.private_b
  to   = module.web_service.aws_subnet.private_b
}

moved {
  from = aws_subnet.public_a
  to   = module.web_service.aws_subnet.public_a
}

moved {
  from = aws_subnet.public_b
  to   = module.web_service.aws_subnet.public_b
}
