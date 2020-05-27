import json
import os

import boto3


def handle_webhook(event, context):
    print("Event: {}".format(event))
    project_name = os.environ['PROJECT_NAME']
    (url, branch, commit) = parse_event(event)
    cb = boto3.client('codebuild')
    build = {
        'projectName': project_name,
        'environmentVariablesOverride': [
            {
                'name': 'GIT_BRANCH',
                'value': branch,
                'type': 'PLAINTEXT'
            },
            {
                'name': 'GIT_COMMIT',
                'value': commit,
                'type': 'PLAINTEXT'
            },
            {
                'name': 'GIT_URL',
                'value': url,
                'type': 'PLAINTEXT'
            }
        ]
    }
    print('Starting build for project {0} (branch {1}, commit {2}).'
          .format(project_name, branch, commit))
    try:
        build = cb.start_build(**build)
        print('Build started successfully.')
        print('Codebuild returned: {}'.format(build))
    except Exception as e:
        print('Codebuild error: {}'.format(e))
        raise
    return {
        'statusCode': 204
    }


def parse_event(event):
    body = json.loads(event['body'])
    url = body['project']['git_http_url']
    object_kind = body['object_kind']
    if object_kind == 'push':
        branch = remove_prefix(body['ref'], 'refs/heads/')
        commit = body['checkout_sha']
        return url, branch, commit
    elif object_kind == 'merge_request':
        object_attributes = body['object_attributes']
        branch = object_attributes['source_branch']
        commit = object_attributes['last_commit']['id']
        return url, branch, commit
    else:
        raise Exception('Unsupported event kind: {}'.format(object_kind))


def remove_prefix(text, prefix):
    if text.startswith(prefix):
        return text[len(prefix):]
    return text
