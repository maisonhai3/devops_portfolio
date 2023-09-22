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
  name_prefix = "httpd-server"
  image_id = "ami-06ae1c4aad8f3da47"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.typical_sg.id]
  key_name = "CICD_kp"
  
  user_data = filebase64("./one_line_site.sh")
}

resource "aws_autoscaling_group" "typical_asg" {
  name_prefix = "httpd-server-asg"
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  desired_capacity = 1
  min_size = 1
  max_size = 3

  launch_template {
    id = aws_launch_template.httpd-server.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "typical_sg" {
  name = var.project_tag

  ingress {
    from_port = var.incoming_port
    to_port = var.incoming_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "lb-for-httpd-server-asg" {
  name = "lb-for-httpd-server-asg" 
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "httpd" {
  load_balancer_arn = aws_lb.lb-for-httpd-server-asg.arn
  port = "80"
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
  name = "httpd-server-target-group"
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
resource "aws_security_group" "alb" {
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
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