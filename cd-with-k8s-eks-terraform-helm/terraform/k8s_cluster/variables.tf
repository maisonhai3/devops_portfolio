variable "region_name" {
    type = string
    default = "us-east-2"
}

variable "ipam_regions" {
  type    = list
  default = ["us-east-1", "us-west-2"]
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}