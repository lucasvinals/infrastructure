
resource "aws_instance" "instance" {
  count = var.ec2Instances.count

  ami           = var.ec2Instances.ami
  instance_type = var.ec2Instances.instance_type

  security_groups = [aws_security_group.instances.name]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World ${count.index}" > index.html
                python3 -m http.server 8080 &
                EOF

  user_data_replace_on_change = true

  tags = {
    Name = "Terraform-PoC ${count.index}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn

  port = 80

  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "instances" {
  name     = "terraform-poc"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance" {
  for_each         = { for idx, value in aws_instance.instance : idx => value }
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = each.value.id
  port             = 8080
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

resource "aws_lb" "alb" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}
