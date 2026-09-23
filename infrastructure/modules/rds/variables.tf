variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group"
}

variable "app_security_group_id" {
  type        = string
  description = "App instances' security group — only this can reach the DB"
}

variable "db_username" {
  type        = string
  description = "Master username for the database"
}

variable "db_password" {
  type        = string
  description = "Master password for the database"
  sensitive   = true
}

variable "db_name" {
  type    = string
  default = "javaappdb"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}