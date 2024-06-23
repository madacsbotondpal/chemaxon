variable "environment" {
    description = "Environment type (development, staging, production)"
    type = string
}

variable "region" {
  description = "Region to deploy"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
}

variable "private_subnet_cidr" {
    description = "CIDR blocks for the private subnets"
    type = list(string)
}

variable "public_subnet_cidr" {
    description = "CIDR blocks for the public subnets"
    type = list(string)
}

variable "availability_zone" {
    description = "Availability zone for the subnet"
    type = list(string)
}