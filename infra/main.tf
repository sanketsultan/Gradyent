terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.8.0"
    }
  }
  backend "s3" {
    bucket         = "gradyent-terraform-state"
    key            = "gradyent/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
