# BotTech/codebuild-gitlab-webhook/aws

https://registry.terraform.io/modules/BotTech/codebuild-gitlab-webhook/aws/

Terraform module for AWS CodeBuild which receives GitLab webhooks and starts a build.

This exists to workaround the lack of built in GitLab support within AWS CodeBuild. There is a feature request to
[integration GitLab with AWS CodeBuild].

The quickest way to get started is to refer to one of the examples above 👆.

## Configuration

### Roles

In order to use this module you need to define two roles.

The first role is very basic, it just allows AWS Lambda to execute:

```hcl-terraform
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
```

The second role is a service role that can be used by CodeBuild.

Here is the basic policy which is from the documentation on how to [create a CodeBuild service role]:

```hcl-terraform
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

resource "aws_iam_role_policy_attachment" "code_build" {
  role       = aws_iam_role.code_build_service.name
  policy_arn = aws_iam_policy.code_build.arn
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
}
```

> ℹ️ If your build needs to perform additional actions then you can attach additional policies to the `code_build` role.

### CodeBuild Project

The next thing that you need is to define the `aws_codebuild_project`.

Since there is obviously no GitLab integration you need to set the source type to `NO_SOURCE`.

When the build is started the following environment variables will be provided from the GitLab event:
* `GIT_BRANCH`
* `GIT_COMMIT`
* `GIT_URL`

You can use these environment variables in your buildspec file to checkout the GitLab repository. For example:

```
git clone --branch "${GIT_BRANCH}" --no-checkout "${GIT_URL/:\/\//://oauth2:${GITLAB_TOKEN}@}"
git checkout "${GIT_COMMIT}"
```

> ⚠️ For added security you should not use the `GIT_URL` environment variable and hard code it instead. If an attacker
> is able to make a request to trigger a build then they could inject malicious code into your build.

### Secrets

In order to checkout the GitLab repository we need to store the GitLab OAuth in AWS Secrets Manager:

```hcl-terraform
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
```

Edit your buildspec to retrieve the token:

```yaml
env:
  secrets-manager:
    GITLAB_TOKEN: GitLabToken
```

## Module

Now that you have all the prerequisites you can configure the module:

```hcl-terraform
module "build_example_image_webhook" {
  source  = "BotTech/codebuild-gitlab-webhook/aws"
  version = "1.0.1"

  authorizer_role_arn = aws_iam_role.lambda_basic_service.arn
  project_name        = aws_codebuild_project.build.name
  role_arn            = aws_iam_role.code_build_service.arn
}
```

## GitLab

Finally you can use the outputs of the module to create the webhook in GitLab:

```hcl-terraform
provider "gitlab" {
  token = var.gitlab_token
}

resource "gitlab_project_hook" "community" {
  project     = "bottech/community-systems/community"
  url         = module.build_example_image_webhook.invoke_url
  push_events = true
  token       = module.build_example_image_webhook.token
}
```

> ⚠️ Currently only `push_events` and `merge_request_events` are supported.

## Applying

The very last thing to do before you can apply this configuration is to setup the GitLab token variables:

```hcl-terraform
variable "gitlab_token" {
  description = "The GitLab personal access token. The token must have api scope."
  type        = string
}

variable "gitlab_oauth_token" {
  description = "The GitLab OAuth token. The token must have api scope."
  type        = string
}
```

### Personal Access Token

You need to [create a personal access token] with `api` scope so that you may use Terraform's GitLab provider.

### OAuth Token

The final step is to obtain an OAuth token.

1. Create an [OAuth application in the Admin area] with `api` scope and a Redirect/Callback URL to a domain which you
control.

    > ⚠️ There should not be any third-party scripts, for example trackers and advertisements, at the URL used for the
    > Redirect/Callback URL. Doing so can compromise the token and give third party full access to your GitLab account.

    > ℹ️ Take note of the `Application ID` and `Secret`.

1. You need to generate a random state value that is difficult to guess:

    ```shell script
    cat /dev/urandom | head -c 32 | shasum -a 256 -b | cut -d " " -f1
    ```

1. Now create the authorization URL:

    ```text
    https://gitlab.com/oauth/authorize?client_id=<APP_ID>&redirect_uri=<REDIRECT_URL>&state=<STATE>&response_type=code&scope=api
    ```

    Replace `<APP_ID>`, `<REDIRECT_URL>` and `<STATE>` with the values from earlier.

    > ⚠️ Remember to URL encode the Redirect URL. You can use [urlencoder] to do this.

1. Open the authorization URL in a browser and authorize the application.

    > ℹ️ This will redirect you to your Redirect URL.
    > Take note of the `code` query parameter in the URL which will be used as the `<RETURNED_CODE>` in the next step.

1. Now obtain a token

    ```text
    curl --verbose --request POST 'https://gitlab.com/oauth/token?client_id=<APP_ID>&client_secret=<APP_SECRET>&code=<RETURNED_CODE>&grant_type=authorization_code&redirect_uri=<REDIRECT_URL>'
    ```

    Replace `<APP_ID>`, `<APP_SECRET>`, `<RETURNED_CODE>`, `<REDIRECT_URL>` with the values from earlier.

    > The `access_token` returned in the body of the response is what you can now use as the value of the
    > `gitlab_oauth_token` Terraform variable.

## License

```text
Copyright 2020 BotTech.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this repository except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[create a codebuild service role]: https://docs.aws.amazon.com/codebuild/latest/userguide/setting-up.html#setting-up-service-role
[create a personal access token]: https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#creating-a-personal-access-token
[integration gitlab with aws codebuild]: https://gitlab.com/gitlab-org/gitlab/-/issues/19081
[oauth application in the admin area]: https://docs.gitlab.com/ee/integration/oauth_provider.html#oauth-applications-in-the-admin-area
[urlencoder]: https://www.urlencoder.io/
