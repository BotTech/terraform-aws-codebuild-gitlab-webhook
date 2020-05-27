output "invoke_url" {
  description = "URL to invoke the webhook. This should be provided as the `url` to the `gitlab_project_hook` resource."
  value       = aws_api_gateway_deployment.start_build.invoke_url
}

output "token" {
  description = "The token to provide when invoking the webhook. This should be provided as the `token` to the `gitlab_project_hook` resource."
  value       = random_password.token.result
}
