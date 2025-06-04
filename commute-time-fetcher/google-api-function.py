# The journey, :D

#extract address and destination from json, 
#send that address and destination w your API keys to request distance

#Ex:
# https://maps.googleapis.com/maps/api/distancematrix/json?origins=Seattle&destinations=San+Francisco&key=YOUR_API_KEY


import requests
from decimal import Decimal
import json
url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
API_KEY = ''
results = []
headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
}

def lambda_handler(event, context):
    body = json.loads(event["body"])  
    for match in body["matches"]:
        user_id = match["user_id"]
        origin = match["origin_address"]
        destination = match["destination_address"]
        phone = match["phone_number"]

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

        
        
    
    

API_KEY = ''
origin = ''
destination = ''
arrival_time = '1748915692'





response = requests.get(url, params=params)
data = response.json()



