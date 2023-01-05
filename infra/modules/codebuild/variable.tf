variable name {
  type    = string
}

variable region {
  description = "AWS region"
  type        = string
}

variable eksclustername {
  description = "EKS Cluster Name"
  type        = string
}

variable deploy_env {
  description = "Deployment environemnt"
  type        = string
}

variable k8sfiles {
  description = "comma seperated list of files"
  type        = string
}

variable s3_source{
  description = "s3 Source bucket with full path"
  type        = string
}

variable s3_arn{
  description = "s3 Source bucket with full path"
  type        = string
}

variable codebuild_role_arn{
  description = "role associated with codebuild "
  type        = string
}
