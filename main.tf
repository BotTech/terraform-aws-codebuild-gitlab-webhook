locals {
  default_name  = "start-build-${var.project_name}"
  api_name      = var.api_name == null ? local.default_name : var.api_name
  function_name = var.function_name == null ? local.default_name : var.function_name
  authorizer_name = var.authorizer_name == null ? "authorize-${var.project_name}" : var.authorizer_name
}

resource "random_password" "token" {
  length  = 65
  special = false
}
