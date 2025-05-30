import boto3
from datetime import datetime, timedelta, timezone

dynamodb = boto3.resource('dynamodb')
sns = boto3.resource('sns')

TABLE_NAME = 'google-project-table'
SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:463470969308:arriveby-alert-sns'


def lambda_handler(event, context):
    table = dynamodb.Table(TABLE_NAME)
    now = datetime.now(timezone.est)
    one_hour_later = now + timedelta(hours=1)

    response = table.scan()
    for item in response['Items']:
        reminder_time = item.get('arrival_time')
        if not reminder_time:
            continue
        print(reminder_time)
        print(now)
        print(one_hour_later)

    