terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
# Using the default configuration 
# and credentials file from ~/.aws/ directory
provider "aws" {
  region = var.region
}
