resource "aws_codebuild_project" "build" {
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type  = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"
    ]
  }
  description  = var.build_description
  environment {
    compute_type = var.build_compute_type
    image        = var.build_image
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "GIT_BRANCH"
      value = "master"
    }
    environment_variable {
      name  = "GIT_COMMIT"
      value = "master"
    }
    environment_variable {
      name  = "GIT_URL"
      value = var.gitlab_url
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    type         = "LINUX_CONTAINER"
  }
  name         = var.build_name
  service_role = aws_iam_role.code_build_service.arn
  source {
    buildspec = var.build_spec
    type      = "NO_SOURCE"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
