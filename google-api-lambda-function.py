import json

def handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Data received successfully",
                "received": body
            })
        }
    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": str(e)})
        }
