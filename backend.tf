terraform {
  backend "s3" {
    bucket = var.bucket_name
    key    = "global/s3/terraform.tfstate"
    region = var.aws_region
  }
}
