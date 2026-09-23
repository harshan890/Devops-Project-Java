# Log group where app logs will be stored (Tomcat instances can push logs here later via CloudWatch agent)
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/java-app/application"
  retention_in_days = 14

  tags = {
    Name = "java-app-logs"
  }
}

# Alarm: alert if average CPU across the ASG goes above 70% for 2 consecutive checks
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "java-app-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name          = "CPUUtilization"
  namespace           = "AWS/EC2"
  period               = 120
  statistic            = "Average"
  threshold            = 70

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_description = "Triggers when average CPU exceeds 70%"
}

# IAM role so VPC can publish flow logs to CloudWatch
resource "aws_iam_role" "flow_log_role" {
  name = "java-app-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "java-app-flow-log-policy"
  role = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# Log group specifically for VPC network traffic
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/java-app/vpc-flow-logs"
  retention_in_days = 14
}

# Turns on flow logging for your VPC (tracks all network traffic in/out)
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}