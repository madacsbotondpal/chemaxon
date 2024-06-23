# Returning IDs (VPC and subnet) for future use (e.g. creating VMs)
output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = aws_subnet.private[*].id
}