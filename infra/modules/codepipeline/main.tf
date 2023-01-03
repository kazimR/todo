data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

resource "aws_codepipeline" "wt" {
  name     = var.name
  role_arn = "arn:aws:iam::765542892778:role/AWS-CodePipeline-Service"

  artifact_store {
    location = var.bucketlocation
    type     = "S3"

    encryption_key {
      id   = "arn:aws:kms:eu-west-1:765542892778:alias/aws/s3"
      type = "KMS"
    }
  }
  

  stage {
    name = "Source"
    
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["test"]

      configuration = {
        Repo   = "todo"
        Branch = "feature/ktest"
        PollForSourceChanges = "false"
        Owner  = "KazimR"
        OAuthToken= "Test"
      }
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

# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
# Would probably be better to pull this from the environment
# or something like SSM Parameter Store.
locals {
  webhook_secret = "testsecret"
}

resource "aws_codepipeline_webhook" "wt" {
  name = var.name
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.wt.name
  

  authentication_configuration {
    secret_token = local.webhook_secret
      }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/feature/ktest"
  }
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "wt" {
  repository = "todo"

  

  configuration {
    url          = aws_codepipeline_webhook.wt.url
    content_type = "json"
    insecure_ssl = true
    secret       = local.webhook_secret
  }

  events = ["push"]
}