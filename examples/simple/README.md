# Simple Example

This is a simple example of using `BotTech/codebuild-gitlab-webhook/aws` to create a webhook which
receives push events from a GitLab repository and builds it using AWS CodeBuild.

## Configuration

### BuildSpec

You need to create a buildspec such as:

```yaml
version: 0.2

env:
  secrets-manager:
    GITLAB_TOKEN: GitLabToken

phases:
  pre_build:
    commands:
      - echo Checking out commit "${GIT_COMMIT}" on branch "${GIT_BRANCH}" from repository "${GIT_URL}"...
      - git clone --branch "${GIT_BRANCH}" --no-checkout "${GIT_URL/:\/\//://oauth2:${GITLAB_TOKEN}@}" src
      - cd src
      - git checkout "${GIT_COMMIT}"
  build:
    commands:
      - echo Build started on `date`
      - echo Building...
      - bin/build.sh
  post_build:
    commands:
      - echo Build completed on `date`
```

```hcl-terraform
data "local_file" "buildspec" {
  filename = "${path.module}/files/buildspec.yml"
}
```

### Example

```hcl-terraform
module "codebuild-gitlab-webhook_example_simple" {
  source  = "BotTech/codebuild-gitlab-webhook/aws//examples/simple"
  version = "1.0.1"

  build_description  = "Example of a build triggered by a GitLab webhook."
  build_name         = "Example"
  build_spec         = data.local_file.buildspec.content
  gitlab_oauth_token = var.gitlab_oauth_token
  gitlab_token       = var.gitlab_token
  gitlab_url         = "https://gitlab.com/org/project"
}
```

#### GitLab Tokens

Refer to the [main README] for instructions on how to obtain the values for the `gitlab_token` and `gitlab_oauth_token`
variables. 

## License

![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")

To the extent possible under law, [BotTech] has waived all copyright and related or neighboring rights to
`BotTech/codebuild-gitlab-webhook/aws//examples/simple`.

[bottech]: https://github.com/BotTech/terraform-aws-codebuild-gitlab-webhook
[main readme]: ../../README.md#applying
