module "vpc" {
  source = "../../modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = var.node_instance_types
  desired_size        = var.desired_size
  min_size            = var.min_size
  max_size            = var.max_size

  environment = var.environment
}