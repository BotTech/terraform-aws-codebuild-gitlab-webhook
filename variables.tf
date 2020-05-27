variable "api_name" {
  default     = null
  description = "Name of the APIGateway REST API for the webhook. Defaults to \"start-build-$${var.project_name}\" if not provided."
  type        = string
}

variable "authorizer_name" {
  default     = null
  description = "Name of the Lambda function which authorizes the request. Defaults to \"authorize-$${var.project_name}\" if not provided."
  type        = string
}

variable "authorizer_role_arn" {
  description = "ARN of the IAM role to attach to the authorizer function."
  type        = string
}

variable "function_name" {
  default     = null
  description = "Name of the Lambda function which starts the build. Defaults to \"start-build-$${var.project_name}\" if not provided."
  type        = string
}

variable "project_name" {
  description = "Name of the CodeBuild project which to build."
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role to attach to the Lambda function which starts the build."
  type        = string
}
