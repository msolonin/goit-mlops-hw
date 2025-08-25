
variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile name for authentication"
  type        = string
}

variable "enable_cluster_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "enable_cluster_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_admin_users" {
  description = "List of IAM user ARNs to be granted cluster admin access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones in the region"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}


variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "cpu_desired_capacity" {
  description = "Desired number of instances in the CPU node group"
  type        = number
}

variable "cpu_max_capacity" {
  description = "Maximum number of instances in the CPU node group"
  type        = number
}

variable "cpu_min_capacity" {
  description = "Minimum number of instances in the CPU node group"
  type        = number
}

variable "gpu_desired_capacity" {
  description = "Desired number of instances in the GPU node group"
  type        = number
}

variable "gpu_max_capacity" {
  description = "Maximum number of instances in the GPU node group"
  type        = number
}

variable "gpu_min_capacity" {
  description = "Minimum number of instances in the GPU node group"
  type        = number
}
