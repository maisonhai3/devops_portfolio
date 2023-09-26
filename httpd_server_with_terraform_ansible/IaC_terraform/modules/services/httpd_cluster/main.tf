terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"

    default_tags {
      tags = {
        Project = "httpd-by-terraform"
      }
    }
}

# NETWORKING
variable "incoming_port" {
  type = number
  default = 80
}

data "aws_vpc" "default" {
  default = true
}

# ASG
resource "aws_launch_template" "httpd-server" {
  name_prefix = var.cluster_name

  image_id = "ami-06ae1c4aad8f3da47"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.services_sg.id]
  key_name = "CICD_kp"
  
  user_data = filebase64("${path.module}/launch_template_user_data.sh")
  # user_data = templatefile("${path.module}/launch_template_user_data.sh")
}

resource "aws_security_group" "services_sg" {
  name = "${var.cluster_name}-sg"

  ingress {
    from_port = local.http_port
    to_port = local.http_portar.incoming_port
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
}

resource "aws_autoscaling_group" "typical_asg" {
  name_prefix = "${var.cluster_name}-asg"
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  desired_capacity = 1
  min_size = var.min_size
  max_size = var.max_size

  launch_template {
    id = aws_launch_template.httpd-server.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = var.cluster_name
    propagate_at_launch = true
  }
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = local.all_ips
}

resource "aws_security_group" "alb" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = local.all_ips
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = local.all_ips
  }
}

resource "aws_lb" "lb-for-httpd-server-asg" {
  name = "${var.cluster_name}-lb" 
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "httpd" {
  load_balancer_arn = aws_lb.lb-for-httpd-server-asg.arn
  port = local.http_port
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

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.httpd.arn
  priority = 100 # what is this?

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {
  name = "${var.cluster_name}-lb-tg" 
  port = var.incoming_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

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



# # MONITORING
# resource "aws_cloudwatch_dashboard" "name" {
# }

# resource "aws_sns_topic" "name" {
# }

output "alb_dns_name" {
  value = aws_lb.lb-for-httpd-server-asg.dns_name
  description = "The domain name of the load balancer"
}