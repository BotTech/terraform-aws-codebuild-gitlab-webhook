module "build_example_image_webhook" {
  source  = "bottech/codebuild-gitlab-webhook/aws"
  version = "1.0.0"

  authorizer_role_arn = aws_iam_role.lambda_basic_service.arn
  project_name        = aws_codebuild_project.build_example_image.name
  role_arn            = aws_iam_role.code_build_service.arn
}
