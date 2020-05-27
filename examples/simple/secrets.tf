resource "aws_secretsmanager_secret" "gitlab_token" {
  description = "GitLab application OAuth token."
  name        = "GitLabToken"
  # This ought to have an expiry and be rotated but it doesn't.
  # See https://gitlab.com/gitlab-org/gitlab/-/issues/21745.
  policy      = data.aws_iam_policy_document.get_gitlab_token.json
}

data aws_iam_policy_document "get_gitlab_token" {
  statement {
    actions   = [
      "secretsmanager:GetSecretValue"
    ]
    principals {
      identifiers = [
        aws_iam_role.code_build_service.arn
      ]
      type        = "AWS"
    }
    resources = [
      "*"
    ]
  }
}

resource "aws_secretsmanager_secret_version" "gitlab_token" {
  secret_id     = aws_secretsmanager_secret.gitlab_token.id
  secret_string = var.gitlab_oauth_token
}
