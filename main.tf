provider "aws" {
  region = var.region
  
  default_tags {
    tags = var.tags
  }
}


module "vpc" {
  source                         = "./vpc"

  vpc_name                       = var.vpc_name
  vpc_cidr                       = var.vpc_cidr
  availability_zones             = var.availability_zones
  public_subnets                 = var.public_subnets
  private_subnets                = var.private_subnets
  tags                           = var.tags
}

module "eks" {
  source                         = "./eks"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cpu_desired_capacity           = var.cpu_desired_capacity
  cpu_max_capacity               = var.cpu_max_capacity
  cpu_min_capacity               = var.cpu_min_capacity
  enable_cluster_private_access  = var.enable_cluster_private_access
  enable_cluster_public_access   = var.enable_cluster_public_access
  cluster_public_access_cidrs    = var.cluster_public_access_cidrs
  cluster_admin_users            = var.cluster_admin_users
  gpu_desired_capacity           = var.gpu_desired_capacity
  gpu_max_capacity               = var.gpu_max_capacity
  gpu_min_capacity               = var.gpu_min_capacity
  tags                           = var.tags
  vpc_id                         = module.vpc.vpc_id
  private_subnets                = module.vpc.private_subnets

  depends_on = [module.vpc]

}