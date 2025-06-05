# The journey, :D

#extract address and destination from json, 
#send that address and destination w your API keys to request distance

#Ex:
# https://maps.googleapis.com/maps/api/distancematrix/json?origins=Seattle&destinations=San+Francisco&key=YOUR_API_KEY


import requests
import json
import boto3
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
        
def lambda_handler(event, context):
    results = []
    body = json.loads(event["body"])  
    for match in body["matches"]:
        user_id = match["user_id"]
        origin = match["origin_address"]
        destination = match["destination_address"]
        phone = match["phone_number"]
        arrival_time = match["arrival_time"]

        params = {
            'origins': origin,
            'destinations': destination,
            'arrival_time': arrival_time,
            'key': API_KEY  
         }
        
        response = requests.get(url,params)
        data = response.json()
        if data['rows'][0]['elements'][0]['status'] == 'OK':
            duration_in_traffic = data['rows'][0]['elements'][0]['duration']['text']
            results.append({'user_id': user_id, 'phone_number': phone, 'duration_in_traffic': duration_in_traffic})
        else:
            print('error')
    return {
        "statusCode": 200,
        "headers": headers,
        "body": json.dumps({"results": results}, default=str)
    }

        
        
    
    
