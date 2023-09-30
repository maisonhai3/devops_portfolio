terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
    region = var.region

    default_tags {
      tags = {
        Project = "cd-retail-web"
      }
    }
}

# terraform {
#   backend "s3" {
#     bucket = "httpd-server-terraform-state"
#     key = "cd-retail-web/k8s-cluster/terraform.tfstate"
#     region = "us-east-2"

#     dynamodb_table = "terraform_state_locks"
#     encrypt = true
#   }
# }