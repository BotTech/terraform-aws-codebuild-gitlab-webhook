provider "gitlab" {
  token = var.gitlab_token
}

module "build_example_image_webhook" {
  source  = "BotTech/codebuild-gitlab-webhook/aws"
  version = "1.0.3"

  authorizer_role_arn = aws_iam_role.lambda_basic_service.arn
  project_name        = aws_codebuild_project.build.name
  role_arn            = aws_iam_role.code_build_service.arn
}

resource "gitlab_project_hook" "community" {
  project     = "bottech/community-systems/community"
  url         = module.build_example_image_webhook.invoke_url
  push_events = true
  token       = module.build_example_image_webhook.token
}
