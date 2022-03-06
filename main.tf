provider "aws" {
    region = var.region
    profile = var.profile
}

locals {
  addl_tags = {
      project = "Learn LB"
  }
  azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

module "vpc" {
  source = "./modules/vpc"
  address_space = "10.0.0.0/16"
  subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24","10.0.4.0/24" ]
  azs = local.azs
  addl_tags = local.addl_tags
}

module "iam" {
  source = "./modules/iam"
  addl_tags = local.addl_tags
}

module "asg" {
  source = "./modules/asg"
  iam_instance_profile_name = module.iam.iam_instance_profile.name
  vpc = module.vpc.id
  subnet_ids = module.vpc.subnet_ids
  addl_tags = local.addl_tags
}

output "lb_url" {
  value = "http://${module.asg.dns_name}"
}