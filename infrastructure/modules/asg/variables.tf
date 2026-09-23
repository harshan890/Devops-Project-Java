variable "aws_vpc" {
    type = string
    description = "VPC ID"
}

variable "private_subnet_ids" {
    type = list(string)
    description = "List of private subnet IDs"
}

variable "alb_security_group_id" {
    type = string
    description = "Security group ID for the ALB"
}

variable "target_group_arn" {
    type = string
    description = "ARN of the target group for the ALB"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "Key pair name for SSH access"
}