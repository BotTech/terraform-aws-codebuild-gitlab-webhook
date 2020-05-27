resource "aws_lambda_function" "verify_token" {
  description      = "Verifies the token."
  environment {
    variables = {
      GITLAB_TOKEN = random_password.token.result
    }
  }
  filename         = data.archive_file.verify_token.output_path
  function_name    = local.authorizer_name
  handler          = "verifier.verify_token"
  role             = var.authorizer_role_arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.verify_token.output_base64sha256
}

data "archive_file" "verify_token" {
  type        = "zip"
  source_file = "${path.module}/functions/verify-token/verifier.py"
  output_path = "${path.module}/outputs/verify-token.zip"
}

resource "aws_lambda_permission" "verify_token" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.verify_token.function_name
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowAPIGatewayInvoke"
  source_arn    = "${aws_api_gateway_rest_api.start_build.execution_arn}/*/*"
}

resource "aws_lambda_function" "start_build" {
  description      = "Handles the events from GitLab and starts a build for the ${var.project_name} CodeBuild project."
  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }
  filename         = data.archive_file.start_build.output_path
  function_name    = local.function_name
  handler          = "handler.handle_webhook"
  role             = var.role_arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.start_build.output_base64sha256
}

data "archive_file" "start_build" {
  type        = "zip"
  source_file = "${path.module}/functions/start-build/handler.py"
  output_path = "${path.module}/outputs/start-build.zip"
}

resource "aws_lambda_permission" "start_build_api" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_build.function_name
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowAPIGatewayInvoke"
  source_arn    = "${aws_api_gateway_rest_api.start_build.execution_arn}/*/*"
}
