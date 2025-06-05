# The journey, :D

#extract address and destination from json, 
#send that address and destination w your API keys to request distance

#Ex:
# https://maps.googleapis.com/maps/api/distancematrix/json?origins=Seattle&destinations=San+Francisco&key=YOUR_API_KEY


import requests
import json
import boto3
from datetime import datetime, timedelta, timezone
import re
url = 'https://maps.googleapis.com/maps/api/distancematrix/json'

headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
}

secret_name = "google_api_key"
region_name = "us-east-1"

def get_secret():
    client = boto3.client("secretsmanager", region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret_str = response.get("SecretString")
        if secret_str:
            return secret_str
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return None

API_KEY = get_secret()



def parse_duration(duration_text):
    hours = 0
    minutes = 0
    
    h = re.search(r"(\d+)\s*hour", duration_text)
    if h:
        hours = int(h.group(1))
    
    m = re.search(r"(\d+)\s*min", duration_text)
    if m:
        minutes = int(m.group(1))
    return timedelta(hours=hours, minutes=minutes)

        
def lambda_handler(event, context):
    results = []
    body = json.loads(event["body"])

    for match in body["matches"]:
        user_id = match["user_id"]
        origin = match["origin_address"]
        destination = match["destination_address"]
        phone = match["phone_number"]
        email_address = match["email_address"]

        
        try:
            arrival_dt = datetime.strptime(match["arrival_time"], '%Y-%m-%d %H:%M:%S%z')
        except ValueError:
            arrival_dt = datetime.strptime(match["arrival_time"], '%Y-%m-%d %H:%M:%S')
            arrival_dt = arrival_dt.replace(tzinfo=timezone.utc)

        arrival_time = int(arrival_dt.timestamp())

    
        params = {
            'origins': origin,
            'destinations': destination,
            'arrival_time': arrival_time,
            'key': API_KEY
        }

        response = requests.get(url, params=params)
        data = response.json()

        if data['rows'][0]['elements'][0]['status'] == 'OK':
            duration_text = data['rows'][0]['elements'][0]['duration']['text']
            traffic_duration = parse_duration(duration_text)
            predicted_depart_time = arrival_dt - traffic_duration
            predicted_depart_time_ts = int(predicted_depart_time.timestamp())

            results.append({
                'user_id': user_id,
                'phone_number': phone,
                'duration_in_traffic': duration_text,
                'email_address': email_address,
                'arrival_time': arrival_time,
                'predicted_depart_time': predicted_depart_time_ts
            })
        else:
            print(f"API error for user {user_id}: {data['rows'][0]['elements'][0]['status']}")

    return {
        "statusCode": 200,
        "headers": headers,
        "body": json.dumps({"results": results}, default=str)
    }
