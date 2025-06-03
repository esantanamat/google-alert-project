import boto3
from datetime import datetime, timedelta, timezone


dynamodb = boto3.resource('dynamodb')
sns = boto3.resource('sns')

TABLE_NAME = 'google-project-table'
SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:463470969308:arriveby-alert-sns'

#This lambda function should get triggered by cloudwatch events
def lambda_handler(event, context):
    table = dynamodb.Table(TABLE_NAME)
    now = datetime.now(timezone.utc)
    one_hour_later = now + timedelta(hours=1)
    nowhformat = now.strftime('%H:%M:%S')
    one_hour_later_hformat = one_hour_later.strftime('%H:%M:%S')

    response = table.scan()
    for item in response['Items']:
        id = item.get('user_id')
        one_time_toggle = item.get('is_one_time')
        if one_time_toggle == 'yes':
            reminder_time = item.get('arrival_time')
            if not reminder_time:
                continue
            within_next_hour =  nowhformat <= reminder_time <= one_hour_later_hformat
            
            if within_next_hour:
                print(f'it is within the next hour ${id} ${reminder_time}')
                #better to invoke another labmda function that handles the google api call
            else:
                continue
        else:
            reminder_time = item.get('arrival_datetime')
            if not reminder_time:
                continue
            within_next_hour = now <= reminder_time <= one_hour_later
            if within_next_hour:
                print(f'it is within the next hour (1 time thing format) ${id} ${reminder_time}')        
        
       