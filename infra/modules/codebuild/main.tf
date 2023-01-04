resource "aws_codebuild_project" "wt" {
  name          = var.name
  description   = "test_codebuild_project"
  build_timeout = "30"
  service_role  = aws_iam_role.wt.arn

  artifacts {
    type = "NO_ARTIFACTS"
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

  source{
   type ="S3"
   location = "${aws_s3_bucket.code.bucket}/todo/infra/env/${var.deploy_env}/k8s/"
  }

  # source {
  #   type            = "GITHUB"
  #   location        = "https://github.com/kazimR/todo.git"
  #   git_clone_depth = 1

  #   git_submodules_config {
  #     fetch_submodules = true
  #   }
  # }

  # source_version = "master"

  # vpc_config {
  #   vpc_id = aws_vpc.wt.id

  #   subnets = [
  #     aws_subnet.wt1.id,
  #     aws_subnet.wt2.id,
  #   ]

  #   security_group_ids = [
  #     aws_security_group.wt1.id,
  #     aws_security_group.wt2.id,
  #   ]
  # }

  tags = {
    Environment = "Test"
  }
}

resource "aws_iam_role" "wt" {
  name = var.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "wt" {
  role = aws_iam_role.wt.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": "codestar-connections:UseConnection",
            "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.code.arn}",
        "${aws_s3_bucket.code.arn}/*"
      ]
    },
    {
            "Effect": "Allow",
            "Action": [
                "ssm:Describe*",
                "ssm:Get*",
                "ssm:List*"
            ],
            "Resource": "*"
    },
    {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "eks:*",
            "Resource": "*"
    }    
  ]
}
POLICY
}