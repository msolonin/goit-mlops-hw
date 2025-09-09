variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "project_name" {
  description = "Project prefix"
  type        = string
  default     = "mlops-lesson-10"
}
