# Get linux AMI ID using SSM parameter endpoint  
data "aws_ssm_parameter" "amz_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}
/*
resource "aws_launch_configuration" "asg-conf" {
  image_id        = data.aws_ssm_parameter.linuxAmi.value
  instance_type   = var.ec2-type
  key_name        = "myvpckey"
  security_groups = [aws_security_group.vm_sg.id]
  user_data       = file("index_page.sh")

  lifecycle {
    create_before_destroy = true
  }

}*/

resource "aws_launch_template" "web_template" {
  name                   = "web_template"
  instance_type          = var.ec2-type
  image_id               = data.aws_ssm_parameter.amz_ami.value
  key_name               = "myvpckey"
  vpc_security_group_ids = [aws_security_group.vm_sg.id]

  user_data = filebase64("index_page.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg"
  max_size                  = 6
  min_size                  = 3
  desired_capacity          = 3
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id]
  #launch_configuration      = aws_launch_configuration.asg-conf.name
  launch_template {
    id = aws_launch_template.web_template.id
  }
  #target_group_arns         = [aws_lb_target_group.alb_tg.arn]
  metrics_granularity = "1Minute"

  depends_on = [
    aws_nat_gateway.nat1,
    aws_nat_gateway.nat2,
    aws_nat_gateway.nat3,
  ]
}

# Attach autoscaling group to alb
resource "aws_autoscaling_attachment" "as_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  alb_target_group_arn   = aws_lb_target_group.alb_tg.arn
}

# Use autoscaling simple policy, integrate with CloudWatch metric like CPU utilization
# the policies will scale out instances when the utilization exceed the "scale-up-alarm" threshold
# and scale in instances when the usage below the "sacle-down-alarm" threshold
resource "aws_autoscaling_policy" "scale-up-policy" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  cooldown               = 300
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale-up-alarm" {
  alarm_description   = "monitor the CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale-up-policy.arn]
  alarm_name          = "CPU utiliaztion high alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilizaiton"
  threshold           = "80"
  # The number of periods over which data is compared to the specified threshold
  evaluation_periods = "2"
  statistic          = "Average"
  # The length, in seconds, used each time the metric specified in metric_name
  period = "30"

  dimensions = {
    AutoScalingGruopname = aws_autoscaling_group.asg.name
  }

}

resource "aws_autoscaling_policy" "scale-down-policy" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  cooldown               = 300
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale-down-alarm" {
  alarm_description   = "monitor the CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale-down-policy.arn]
  alarm_name          = "CPU utilization low alarm"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "20"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  period              = "30"
  statistic           = "Average"

  dimensions = {
    AutoScalingGruopname = aws_autoscaling_group.asg.name
  }
}