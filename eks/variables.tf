variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
}

variable "cpu_desired_capacity" {
  description = "Desired capacity for CPU node group"
  type        = number
}

variable "cpu_max_capacity" {
  description = "Maximum capacity for CPU node group"
  type        = number
}

variable "cpu_min_capacity" {
  description = "Minimum capacity for CPU node group"
  type        = number
}

variable "enable_cluster_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "enable_cluster_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "gpu_desired_capacity" {
  description = "Desired capacity for GPU node group"
  type        = number
}

variable "gpu_max_capacity" {
  description = "Maximum capacity for GPU node group"
  type        = number
}

variable "gpu_min_capacity" {
  description = "Minimum capacity for GPU node group"
  type        = number
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "cluster_admin_users" {
  description = "List of IAM user ARNs to be granted cluster admin access"
  type        = list(string)
  default     = []
}