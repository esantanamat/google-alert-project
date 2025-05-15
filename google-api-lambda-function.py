import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('google-project-table')

def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))  

    method = event.get("requestContext", {}).get("http", {}).get("method")
    path = event.get("rawPath")
    headers = {
        "Content-Type": "application/json"
    }

    try:
      
        if method == "POST" and path == "/":
            body = json.loads(event.get("body", "{}"), parse_float=Decimal)

            
            if "user_id" not in body or "destination_name" not in body:
                return {
                    "statusCode": 400,
                    "headers": headers,
                    "body": json.dumps({"error": "Missing user_id or destination_name"})
                }

            table.put_item(Item=body)

            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps({
                    "message": "Item has been added via POST route",
                    "item": body
                })
            }

        else:
            return {
                "statusCode": 404,
                "headers": headers,
                "body": json.dumps({"error": f"No matching route for {method} {path}"})
            }

    except Exception as e:
        print("ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"message": "Internal Server Error", "details": str(e)})
        }
