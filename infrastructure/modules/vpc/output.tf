output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "vpc-name" {
  value = aws_vpc.main.tags["Name"]
}

output "vpc-cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_cidrs" {
  value = aws_subnet.public_subnets[*].cidr_block
}

output "private_subnet_cidrs" {
  value = aws_subnet.private_subnets[*].cidr_block
}

output "public_route_table_ids" {
  value = aws_route_table.second_rt.id
}

output "private_rout_table-ids" {
  value = aws_route_table.second_rt.id
}