resource "aws_security_group" "web" {
  name   = "cloudscale-web-sg-tf"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix            = "cloudscale-web-"
  image_id               = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecr.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y docker
    systemctl enable --now docker
    aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${split("/", aws_ecr_repository.app.repository_url)[0]}
    docker run -d --restart always -p 80:5000 ${aws_ecr_repository.app.repository_url}:${var.image_tag}
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "cloudscale-web-asg"
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 3
  target_group_arns         = [aws_lb_target_group.web.arn]
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "aws_launch_template.web.latest.version"
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }
}


resource "aws_security_group" "alb" {
  name   = "cloudscale-alb-sg-tf"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "cloudscale-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path    = "/"
    matcher = "200"
  }
}

resource "aws_lb" "web" {
  name               = "cloudscale-web-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "cloudscale-cpu-target-50"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}
