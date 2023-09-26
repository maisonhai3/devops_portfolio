terraform {
  backend "s3" {
    bucket = "httpd-server-terraform-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform_state_locks"
    encrypt = true
  }
}
