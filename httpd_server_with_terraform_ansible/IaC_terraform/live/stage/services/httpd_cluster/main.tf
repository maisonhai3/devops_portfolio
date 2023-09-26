terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

module "httpd_cluster" {
    source = "../../../../modules/services/httpd_cluster"

    min_size = 1
    max_size = 2
}