resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }

  tags = {
    Name = "tfstate-bucket"
    Environment = "dev"
  }
}
resource "aws_s3_bucket_public_access_block" "tf_state_block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "vpc" {
  source = "./vpc"
}

module "eks" {
  source = "./eks"
}
