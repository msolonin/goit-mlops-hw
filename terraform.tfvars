region            = "us-east-1"
aws_profile       = "default"
tags = {
  Environment = "dev"
  Project     = "goit-mlops"
  ManagedBy   = "terraform"
}

vpc_name          = "goit-mlops-test-vpc"
vpc_cidr          = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]

enable_cluster_private_access = true
enable_cluster_public_access  = true
cluster_public_access_cidrs   = ["0.0.0.0/0"]

cluster_name      = "goit-mlops-eks-cluster"
cluster_version   = "1.28"
cluster_admin_users = [
  "arn:aws:iam::020236748758:msolonin"
]
cpu_desired_capacity = 1
cpu_max_capacity     = 2
cpu_min_capacity     = 0
gpu_desired_capacity = 0
gpu_max_capacity     = 1
gpu_min_capacity     = 0