data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "java-app-instance-sg"
  description = "Allow traffic only from ALB"
  vpc_id      = var.aws_vpc

  ingress {
    description     = "From ALB only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "java-app-instance-sg"
  }
}

resource "aws_launch_template" "app_lt" {
    name_prefix   = "java-app-lt-"
    image_id      = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    key_name      = var.key_name

    vpc_security_group_ids = [aws_security_group.app_sg.id]

    user_data = base64encode(<<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y java-11-amazon-corretto tomcat
                sudo systemctl enable tomcat
                sudo systemctl start tomcat
                EOF
    )

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "java-app-instance"
        }
    }
}
resource "aws_autoscaling_group" "app_asg" {
  name                = "java-app-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "java-app-asg-instance"
    propagate_at_launch = true
  }
}
