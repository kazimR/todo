data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

resource "aws_codepipeline" "wt" {
  name     = var.name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"

    
  }
  
  stage {
    name = "Source"
    
     action {
       name = "Source"
       category         = "Source"
       owner            = "AWS"
       provider         = "S3"
       version          = "1"
       output_artifacts = ["test"]
       namespace        = "SourceVariables"

       configuration = {
         S3Bucket = var.artifacts_bucket_name
         S3ObjectKey = "todo/test.json"
       }
    }
  }

  stage {
  name = "Approve"

  action {
    name     = "Approval"
    category = "Approval"
    owner    = "AWS"
    provider = "Manual"
    version  = "1"
  }
}

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["test"]
      version         = "1"
      configuration = {
        ProjectName = var.name
      }
   }
  }

}





