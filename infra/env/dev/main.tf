provider "aws" {
  region = "${var.region}"
}

# Terraform S3 State bucket 
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.user}-${var.env}-${var.company}-terraform-state"
 
  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDb for state lock file in case multiple people are working
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.user}-${var.env}-${var.company}-terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Terraform Backend
terraform {
  backend "s3" {
    
    bucket         = "kazim-dev-ktech-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-1"
   

    # Replace this with your DynamoDB table name!
    dynamodb_table = "kazim-dev-ktech-terraform-state"
    encrypt        = true
  }
}

# VPC Creation 

module "vpc" {
  source = "../../modules/vpc"
  environment          = "${var.user}-${var.env}-${var.company}"
  region               = "${var.region}"
  vpc_cidr             = "${var.vpc_cidr}"
  availability_zones   = ["eu-west-1a","eu-west-1b","eu-west-1c"]
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
}
