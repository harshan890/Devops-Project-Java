# Groups your private subnets so RDS knows where it's allowed to live
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "java-app-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "java-app-db-subnet-group"
  }
}

# DB's own security group — only app instances can reach port 3306
resource "aws_security_group" "rds_sg" {
  name        = "java-app-rds-sg"
  description = "Allow MySQL traffic only from app instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app instances only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "java-app-rds-sg"
  }
}

resource "aws_db_instance" "java_app_db" {
  identifier     = "java-app-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.instance_class

  allocated_storage     = 20
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 0
  skip_final_snapshot     = true   # set false for real production use

  tags = {
    Name = "java-app-db"
  }
}