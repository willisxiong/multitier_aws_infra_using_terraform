# Create application load balancer
resource "aws_lb" "alb" {
  name               = "reliable-alb"
  internal           = false
  load_balancer_type = "application"
  # The idle time, in seconds, that the connection allowed to be idle
  idle_timeout    = 90
  security_groups = [aws_security_group.alb_sg.id]
  # Configure the alb in public subnets
  subnets                          = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "alb-external"
  }

}

# Create target group, default target type is instance
resource "aws_lb_target_group" "alb_tg" {
  name     = "reliable-alb-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # If set health check type to ELB in autoscaling group resource
  # You have to add health check block in alb target group resource
  health_check {
    enabled           = true
    healthy_threshold = 3
    # The timeout value must be smaller than the healthe check interval
    timeout = 5
    # The interval is approximate amount of time, in seconds, 
    # between health checks of an individual target
    interval = 30
    # Alb send http health check request to index.html
    path = "/"
    port = 5000
  }

  tags = {
    Name = "alb-tg-asg"
  }
}

/*
resource "aws_lb_target_group_attachment" "poc" {
  target_group_arn = aws_lb_target_group.reliable-alb-targetgroup.arn
  target_id = aws_instance.vm1.id
}*/

# Create port 5000 listener
resource "aws_lb_listener" "alb_listner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

}