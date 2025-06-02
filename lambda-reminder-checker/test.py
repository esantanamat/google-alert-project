import requests

API_KEY = ''
origin = ''
destination = ''
arrival_time = '1748915692'

url = 'https://maps.googleapis.com/maps/api/distancematrix/json'

params = {
    'origins': origin,
    'destinations': destination,
    'arrival_time': arrival_time,
    'key': API_KEY
}

response = requests.get(url, params=params)
data = response.json()


if data['rows'][0]['elements'][0]['status'] == 'OK':
    duration_in_traffic = data['rows'][0]['elements'][0]['duration']['text']
    print(f"Estimated travel time: {duration_in_traffic}")
else:
    print("Failed to get travel time:", data)
