provider "aws" {
    region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "httpd-server-terraform-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform_state_locks"
    encrypt = true
  }
}

resource "aws_db_instance" "http_db" {
    db_name = "mydb"
    identifier_prefix = "httpd-db"

    engine = "mysql"
    instance_class = "db.t2.micro"
    allocated_storage   = 10

    skip_final_snapshot = true
    
    username = var.db_username
    password = var.db_password
}