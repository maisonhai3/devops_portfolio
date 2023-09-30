module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "cd-retail-web-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}



# # VPC
# resource "aws_vpc" "cd_retail_website_vpc" {
#   tags = {
#     Name = "cd-retail-website-vpc"
#   }

#   ipv4_ipam_pool_id   = aws_vpc_ipam_pool.default.id
#   ipv4_netmask_length = 28
#   depends_on = [
#     aws_vpc_ipam_pool_cidr.default
#   ]
# }


# resource "aws_vpc_ipam_pool" "default" {
#   address_family = "ipv4"
#   ipam_scope_id  = aws_vpc_ipam.default.private_default_scope_id
#   locale         = var.region_name
# }

# resource "aws_vpc_ipam_pool_cidr" "default" {
#   ipam_pool_id = aws_vpc_ipam_pool.default.id
#   cidr         = "172.20.0.0/16"
# }

# data "aws_region" "current" {}

# resource "aws_vpc_ipam" "default" {
#   operating_regions {
#     region_name = data.aws_region.current.name
#   }
# }