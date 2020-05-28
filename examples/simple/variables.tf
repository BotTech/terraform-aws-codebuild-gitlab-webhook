variable "build_description" {
  description = "Description of the CodeBuild resource."
  type        = string
}

variable "build_name" {
  description = "Name of the CodeBuild resource."
  type        = string
}

variable "build_compute_type" {
  default     = "BUILD_GENERAL1_SMALL"
  description = "Compute type to use for the CodeBuild resource."
  type        = string
}

variable "build_image" {
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  description = "Image to use for the CodeBuild resource."
  type        = string
}

variable "build_spec" {
  description = "The contents of the buildspec file."
  type        = string
}

variable "gitlab_oauth_token" {
  description = "GitLab OAuth token. The token must have api scope."
  type        = string
}

variable "gitlab_token" {
  description = "GitLab personal access token. The token must have api scope."
  type        = string
}

variable "gitlab_url" {
  description = "The HTTPS URL of the GitLab repository."
  type        = string
}
