import smtplib
from email.mime.text import MIMEText
import json
import boto3

subject = 'Smart Notification Reminder'

def get_secret():
    client = boto3.client("secretsmanager", region_name="us-east-1")
    secret_name = "email_credentials"

    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret_str = response.get("SecretString")
        if secret_str:
            secret_dict = json.loads(secret_str)
            return secret_dict["username"], secret_dict["password"]
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return None, None



def lambda_handler(event, context):
    results = []
    body = json.loads(event["body"])  
    from_email, app_password = get_secret()
    if not from_email or not app_password:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to retrieve email credentials"})
        }
    for match in body["results"]:
        user_id = match["user_id"]
        arrival_time = match["arrival_time"]
        to_email = match["email_address"]
        duration_in_traffic = match["duration_in_traffic"]
        predicted_depart_time = match['predicted_depart_time']
        
        
        message_text = (
            f"Hello,\n\nThis is your reminder for arrival time: {arrival_time}.\n"
            f"Please depart by: {predicted_depart_time}.\n"
            f"Estimated commute time: {duration_in_traffic}.\n\n"
            f"Thank you!\nUser ID: {user_id}"
        )

        msg = MIMEText(message_text)
        msg['Subject'] = subject
        msg['From'] = from_email
        msg['To'] = to_email

        try:
            with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
                server.login(from_email, app_password)
                server.sendmail(from_email, to_email, msg.as_string())
            results.append({'user_id': user_id, 'status': 'sent'})
        except Exception as e:
            print(f"Failed to send email to {to_email}: {e}")
            results.append({'user_id': user_id, 'status': 'failed', 'error': str(e)})

    return {
        "statusCode": 200,
        "body": json.dumps({"results": results})
    }
