resource "aws_codebuild_project" "build_example_image" {
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type  = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"
    ]
  }
  description  = "Builds the example docker image."
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
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
      value = "https://gitlab.com/org/repo.git"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.example_image.name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    privileged_mode = true
    type            = "LINUX_CONTAINER"
  }
  name         = "build-example-image"
  service_role = data.terraform_remote_state.admin.outputs.code_build_service_role_arn
  source {
    buildspec = data.local_file.buildspec.content
    // There is no GitLab integration https://gitlab.com/gitlab-org/gitlab/-/issues/19081
    type      = "NO_SOURCE"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "local_file" "buildspec" {
  filename = "${path.module}/files/buildspec.yml"
}

resource "aws_ecr_repository" "example_image" {
  name = "example-image"

  image_scanning_configuration {
    scan_on_push = true
  }
}
