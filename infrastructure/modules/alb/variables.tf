variable "vpc_id" {
  type        = string
  description = "VPC ID jahan ALB banega"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs jahan ALB place hoga"
}