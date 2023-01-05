resource "aws_codebuild_project" "wt" {
  name          = var.name
  description   = "test_codebuild_project"
  build_timeout = "30"
  service_role  = var.codebuild_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }
  source{
   type ="S3"
   location =  "${var.s3_source}"
  }
  
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true


    environment_variable {
      name  = "k8sfiles"
      value = var.k8sfiles
    } 
    environment_variable {
      name  = "region"
      value = var.region
    } 
    
    environment_variable {
      name  = "eksclustername"
      value = var.eksclustername
    } 

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

  }  
}
