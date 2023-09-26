terraform {
  backend "s3" {
    bucket = "httpd-server-terraform-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform_state_locks"
    encrypt = true
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

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "httpd-server-terraform-state"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
  }
}