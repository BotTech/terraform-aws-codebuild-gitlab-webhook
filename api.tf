resource "aws_api_gateway_rest_api" "start_build" {
  description = "The webhook which received events from GitLab and invokes the Lambda function that will start a build of the ${var.project_name} CodeBuild project."
  name        = local.api_name
}

resource "aws_api_gateway_resource" "proxy" {
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.start_build.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.start_build.id
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.start_build.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.verify_token.id
}

resource "aws_api_gateway_integration" "start_build" {
  rest_api_id             = aws_api_gateway_rest_api.start_build.id
  resource_id             = aws_api_gateway_method.proxy.resource_id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.start_build.invoke_arn
}

// TODO: We don't need both the proxy and proxy_root methods.
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.start_build.id
  resource_id   = aws_api_gateway_rest_api.start_build.root_resource_id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.verify_token.id
}

resource "aws_api_gateway_authorizer" "verify_token" {
  authorizer_uri  = aws_lambda_function.verify_token.invoke_arn
  identity_source = "method.request.header.X-Gitlab-Token"
  name            = "VerifyGitLabToken"
  rest_api_id     = aws_api_gateway_rest_api.start_build.id
  type            = "TOKEN"
}

resource "aws_api_gateway_integration" "start_build_root" {
  rest_api_id             = aws_api_gateway_rest_api.start_build.id
  resource_id             = aws_api_gateway_method.proxy_root.resource_id
  http_method             = aws_api_gateway_method.proxy_root.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.start_build.invoke_arn
}

resource "aws_api_gateway_deployment" "start_build" {
  // Most changes are not applied unless the API is re-deployed.
  // We seem to have to do this manually by creating dependencies.
  depends_on = [
    aws_api_gateway_authorizer.verify_token,
    aws_api_gateway_integration.start_build,
    aws_api_gateway_integration.start_build_root,
  ]
  lifecycle {
    create_before_destroy = true
  }

  rest_api_id = aws_api_gateway_rest_api.start_build.id
  stage_name  = "dev"
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.start_build.id
  stage_name  = "dev"
  method_path = "*/*"

  settings {
    logging_level = "INFO"
  }
}