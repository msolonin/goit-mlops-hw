variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster-msolonin"
}

variable "namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "infra-tools"
}

variable "chart_version" {
  description = "Helm chart version for ArgoCD"
  type        = string
  default     = "5.46.4"
}
