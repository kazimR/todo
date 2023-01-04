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
