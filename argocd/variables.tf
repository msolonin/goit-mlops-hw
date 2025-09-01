variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "lesson7-eks"
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
