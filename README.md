# Smart Travel Reminder
## Inspiration

The idea for this project came while preparing ahead to leave for a destination. I noticed that Apple Maps provides an estimated departure time, but I wanted something more precise. Instead of relying on rough estimates, I decided to create a full-stack application that allows users to enter when they need to arrive somewhere, where they're going, and where they're coming from — and then receive a real-time reminder (via email) when it's time to leave. Note: This feature is available with Google Maps, and Calendar, but the idea was to create a feature that does not require a mobile application. I created this project to stay within the AWS Free tier for dev purposes.

Features
Simple s3 hosted website with a web form for inputting:

* Destination

* Starting location

* Arrival time

* Email address

* Phone Number (to be integrated w twilio in prod)

- Backend calculates real-time traffic data using **Google Maps API**.

- Sends you an email notification when it's time to leave.

- Built with serverless architecture using AWS.

### Tech Stack
- Frontend: HTML/CSS, JS + (planned upgrade to React)

- Backend: AWS Lambda (Python)

- Google Maps Distance Matrix API

- Email Notifications: smtplib python

- Infrastructure: Terraform provisioned AWS resources, i.e step functions, api gateway, lambda, roles, dynamodb,

- State Management: AWS Step Functions

### Live Demo
Coming soon 

### Architecture Diagram
![image](https://github.com/user-attachments/assets/3b3b7b49-e9be-448c-8e9b-b524f5b2250a)
- The user interacts with an s3 static hosted website, which then sends a JSON request routed via API Gateway to a Lambda Function that handles the writing to the dynamodb table.

![image](https://github.com/user-attachments/assets/2e8d793a-ece6-43f1-8b32-bb5ef1996379)


- A cloudwatch events invoked step functions is triggered to orchestrate 3 lambda functions. The first lambda scans the table and determines if the arrival time is within range, the second lambda function fetches the commute time using Google Maps API, and the last function handles sending the user an email.



### Future Improvements for Production
- Add user authentication and history of reminders

- SMS support via Twilio

- React frontend with validation and autocomplete

- Better UI/UX design

- Optimize for mobile devices
  
- Integrate with a calendar system or create a feature that is a calendar system
