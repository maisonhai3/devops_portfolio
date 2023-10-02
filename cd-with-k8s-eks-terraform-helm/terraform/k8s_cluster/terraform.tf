terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.19.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
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

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    # Fetch new token before initializing the provider.
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
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
