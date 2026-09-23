
# Create the VPC
resource "aws_vpc" "main" {   ## create vpc
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Project-VPC"
    }
}
# Public Subnets
resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
# Private Subnets
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)

 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.main.id


tags = {
    Name = "Project VPC IG"
  }
}

# Create a Route Table for Public Subnets
resource "aws_route_table" "second_rt" {
  vpc_id = aws_vpc.main.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id  
  }

  tags = {
    Name = "2nd Route Table"
}
}

# Associate Public Subnets with the Route Table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.second_rt.id
}

# Create a NAT Gateway for Private Subnets
resource "aws_eip" "nat_eip" {
  domain   = "vpc"
  
    tags = {
    Name = "NAT-EIP"
  }
}
# Create a NAT Gateway for Private Subnets
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnets[*].id, 0)
  
  tags = {
    Name = "NAT-GW"
  }
  depends_on = [aws_internet_gateway.gw]
}
# Create a Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id
}