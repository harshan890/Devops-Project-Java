variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_username" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "environment" {
  type = string
}