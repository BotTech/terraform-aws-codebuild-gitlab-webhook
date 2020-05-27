# Simple Example

This is a simple example of using `terraform-aws-codebuild-gitlab-webhook` to create a webhook which receives push
events from a GitLab repository and builds it using AWS CodeBuild.

## Assumptions

This assumes that your repository contains a `bin/build.sh` file.

> ℹ️ Rather than using this example with `terraform init` you may wish to copy it and edit the [build script].

## Applying

In order to apply the changes in this module you will need to provide values for the variables in the
[variables.tf](variables.tf) file.

### GitLab Tokens

Refer to the [main README] for instructions on how to obtain the values for the `gitlab_token` and `gitlab_oauth_token`
variables. 

## License

![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")

To the extent possible under law, [BotTech] has waived all copyright and related or neighboring rights to
`BotTech/codebuild-gitlab-webhook/aws//examples/simple`.

[bottech]: https://github.com/BotTech/terraform-aws-codebuild-gitlab-webhook
[build script]: files/buildspec.yml
[main readme]: ../../README.md
