variable "environment" {
    description = "Current environment to deploy (e.g. development, staging or production)"
    type = string
    default = "development"
}

variable "region" {
    description = "Region to deploy"
    type = string
    default = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
    description = "CIDR blocks for the private subnets"
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidr" {
    description = "CIDR blocks for the public subnets"
    type = list(string)
    default = [ "10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zone" {
    description = "Availability zone for the subnet"
    type = list(string)
    default = [ "eu-central-1a", "eu-central-1b" ]
}
