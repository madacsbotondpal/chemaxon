# I tag all of the resources with Name, Created_by and Creation_date to know who (Terraform) and when the resources were created
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "vpc-${var.environment}"
    Created_by = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

# All resources which are needed for the private subnet can be found below
resource "aws_subnet" "private" {
  count  = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${var.environment}-${count.index + 1}"
    Created_by = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

resource "aws_eip" "nat_elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "nat-elastic-ip-${var.environment}"
    Created_by = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

# Nat gateway is needed to reach services outside of the VPC
# without letting external services to make connection inside the private subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_elastic_ip.id
  subnet_id = element(aws_subnet.public[*].id, 0)
  depends_on = [ aws_internet_gateway.gateway ]
  tags = {
    Name = "nat-gateway-${var.environment}"
    Created_by = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

# Creating the private route table and associating it with the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "private-route-table-${var.environment}"
    Created_by = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(var.private_subnet_cidr)
  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
# /Private resources

# All resources which are needed for the private subnet can be found below
resource "aws_subnet" "public" {
  count  = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "public-subnet-${var.environment}-${count.index + 1}"
    Created_by = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

# An internet gateway is needed to reach the public internet
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet-gateway-${var.environment}"
    Created_by = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

# Creating the public route table and associating it with the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "public-route-table-${var.environment}"
    Created_by = "Terraform"
    Creation_date = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
  lifecycle { ignore_changes = [tags["Create_date"]] }
}

resource "aws_route_table_association" "public_route_table_association" {
  count = length(var.public_subnet_cidr)
  subnet_id = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}
# /Public resources 

# Creating the VPC endpoint for the S3 service
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"

  route_table_ids = [
    aws_route_table.private_route_table.id,
    aws_route_table.public_route_table.id
  ]
}