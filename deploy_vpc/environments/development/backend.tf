# Saving tfstate to S3, so other developers can update, develop new modules
terraform {
  backend "s3" {
    bucket = "vpc-backend-madacsbp"
    key = "develop/terraform.tfstate"
    region = "eu-central-1"
  }
}
