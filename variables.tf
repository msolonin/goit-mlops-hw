variable "aws_region" {
  default     = "us-east-1"
  description = "Default Region"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store Terraform state"
  type        = string
  default     = "mlops-tfstate-msolonin"
}
