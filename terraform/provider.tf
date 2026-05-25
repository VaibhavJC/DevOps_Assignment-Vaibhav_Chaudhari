provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = var.region_name

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = var.endpoint_url
    s3  = var.endpoint_url
    iam = var.endpoint_url
  }

  default_tags {
    tags = {
      Project     = "Sparklehood-Internship"
      Environment = "test"
      Owner       = "Vaibhav Chaudhari"
      Managedby   = "Terraform"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
  }
}