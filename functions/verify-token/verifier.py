import os


def verify_token(event, context):
    token = event['authorizationToken']
    expected_token = os.environ['GITLAB_TOKEN']
    if token == expected_token:
        return grant_access(event, context)
    else:
        return deny_access(event, context)


def grant_access(event, context):
    return create_policy('Allow', event, context)


def deny_access(event, context):
    return create_policy('Deny', event, context)


def create_policy(effect, event, context):
    principal_id = "request|{}".format(context.aws_request_id)
    method_arn = event['methodArn']
    return {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': method_arn
                }
            ]
        }
    }
