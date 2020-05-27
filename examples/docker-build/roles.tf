resource "aws_iam_role" "lambda_basic_service" {
  name               = "LambdaBasicService"
  description        = "Service role for Lambda which is only permitted to execute the lambda function."
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_service" {
  role       = aws_iam_role.lambda_basic_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "code_build_service" {
  name               = "CodeBuildService"
  description        = "Service role for CodeBuild."
  assume_role_policy = data.aws_iam_policy_document.code_build_assume_role.json
}

data "aws_iam_policy_document" "code_build_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = [
        "codebuild.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "code_build" {
  description = "CodeBuild service account access."
  name        = "CodeBuildService"
  policy      = data.aws_iam_policy_document.code_build.json
}

// This policy is quite permissive. In reality you would want to restrict some of these actions to certain resources.
data "aws_iam_policy_document" "code_build" {
  statement {
    sid       = "CloudWatchLogs"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid       = "CodeCommit"
    actions   = [
      "codecommit:GitPull"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid       = "S3BucketIdentity"
    actions   = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid       = "S3GetObject"
    actions   = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid       = "S3PutObject"
    actions   = [
      "s3:PutObject"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid       = "ECRAuth"
    actions   = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid       = "ECRListTags"
    actions   = [
      "ecr:ListTagsForResource"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid       = "ECRPull"
    actions   = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid       = "ECRPush"
    actions   = [
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "*"
    ]
  }
}
