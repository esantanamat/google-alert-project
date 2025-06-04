import boto3
from datetime import datetime, timedelta, timezone
import json

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = 'google-project-table'

headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
}

def lambda_handler(event, context):
    table = dynamodb.Table(TABLE_NAME)
    now = datetime.now(timezone.utc)
    one_hour_later = now + timedelta(hours=1)
    matches = []

    response = table.scan()
    for item in response['Items']:
        id = item.get('user_id')
        one_time_toggle = item.get('is_one_time')

        try:
            if one_time_toggle == 'yes':
                
                parsed_time = datetime.strptime(item.get('arrival_time'), '%H:%M').time()
                reminder_time = now.replace(
                    hour=parsed_time.hour,
                    minute=parsed_time.minute,
                    second=0,
                    microsecond=0
                )
            else:
                
                parsed_datetime = datetime.strptime(item.get('arrival_datetime'), '%Y-%m-%dT%H:%M')
                reminder_time = parsed_datetime.replace(tzinfo=timezone.utc)

            if reminder_time < now:
                reminder_time += timedelta(days=1)

            if now <= reminder_time <= one_hour_later:
                matches.append({'user_id': id, 'reminder_time': reminder_time})

        except Exception as e:
            
            print(f"Error processing item {item}: {e}")
            continue

    return {
        "statusCode": 200,
        "headers": headers,
        "body": json.dumps({"matches": matches}, default=str)
    }
