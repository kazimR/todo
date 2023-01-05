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

# RDS Creation
module "rds" {
  source = "../../modules/rds"
  private_subnet_groups = "${module.vpc.private_subnet_ids}"
  prefix_db = "${var.user}-${var.env}-${var.company}"  

}

#EKS Creation

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.4"

  cluster_name    = "${var.user}-${var.env}-${var.company}"
  cluster_version = "1.24"
  #region          = "${var.region}"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "${var.user}-node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    
  }
}

#myip
module myip{
  source  = "../../modules/myip"

}


#Ingress Policy for each nodes

resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("hello-iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.worker_policy.arn
  role       = each.value.iam_role_name
}

#ALB


resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol  = -1
   
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# ALB
module alb{
  source  = "../../modules/alb"
  lb_name = "${var.user}${var.env}${var.company}"
  public_subnets_ids = module.vpc.public_subnet_ids
  security_groups_ids = [aws_default_security_group.default.id]
}
# S3 Code Bucket
module s3code{
   source  = "../../modules/s3_codebuild"
   name = "${var.user}-${var.env}-${var.company}-repo"
} 

module iam_role_codebuild{
  source  = "../../modules/iam"
  s3_arn =  "${module.s3code.arn}"
  name = "${var.user}-${var.env}-${var.company}"

}

# Code Build EKS
module build{
  source  = "../../modules/codebuild"
  name = "${var.user}-${var.env}-${var.company}"
  region = "${var.region}"
  eksclustername = "${module.eks.cluster_name}"
  deploy_env = "${var.env}"
  k8sfiles = "2048_full.yml,busy-deamonset.yml"
  #s3_source = "/todo/infra/env/${var.env}/k8s/"
  s3_source = "${module.s3code.name}/todo/infra/env/${var.env}/k8s/"
  s3_arn = "${module.s3code.arn}"
  codebuild_role_arn = "${module.iam_role_codebuild.arn}"
}

# # Code Pipeline
# module codepipeline{
#   source  = "../../modules/codepipeline"
#   name = "${var.user}-${var.env}-${var.company}"
#   bucketlocation = "ktestcode"
  
# }





