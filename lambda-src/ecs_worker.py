import os
import sys
import logging
import shlex


logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    import boto3
    client = boto3.client('ecs')
except ImportError:
    logger.error('boto3 is not installed. ECSTasks require boto3')
    sys.exit(1)


def trigger(event, context):
    logger.info('got event{}'.format(event))

    overrides = dict()

    task_definition_arn = os.environ.get('TASK_DEFINITION_ARN')
    if not task_definition_arn:
        logger.error(
            "'TASK_DEFINITION ENVIRONMENT' environment variable not set")
        raise(Exception("task_definition environment variable not set"))

    logger.info('Starting task {}'.format(task_definition_arn))

    task_command = os.environ.get('TASK_COMMAND')
    if task_command:
        logger.info('Custom command: {}'.format(task_command))
        overrides = {'containerOverrides': [{
                    'name': os.environ.get('CONTAINER_NAME'),
                    'command': shlex.split(task_command)
                  }]}
    response = client.run_task(
            cluster=os.environ.get('CLUSTER', 'default'),
            taskDefinition=task_definition_arn,
            overrides=overrides
            )

    ids = ', '.join([task['taskArn'] for task in response['tasks']])

    logger.info('Started tasks {}'.format(ids))

    return {
        'message': 'Started tasks {}'.format(ids)
    }
