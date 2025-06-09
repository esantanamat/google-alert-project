# Smart Travel Reminder
## Inspiration

The idea for this project came while preparing ahead to leave for a destination. I noticed that Apple Maps provides an estimated departure time, but I wanted something more precise. Instead of relying on rough estimates, I decided to create a full-stack application that allows users to enter when they need to arrive somewhere, where they're going, and where they're coming from — and then receive a real-time reminder (via email) when it's time to leave. Note: This feature is available with Google Maps, and Calendar, but the idea was to create a feature that does not require a mobile application. I created this project to stay within the AWS Free tier for dev purposes.

Features
Simple s3 hosted website with a web form for inputting:

Destination

Starting location

Arrival time

Email address

Phone Number (to be integrated w twilio in prod)

Backend calculates real-time traffic data using **Google Maps API**.

Sends you an email notification when it's time to leave.

Built with serverless architecture using AWS.

### Tech Stack
Frontend: HTML/CSS, JS + (planned upgrade to React)

Backend: AWS Lambda (Python)

APIs:

Google Maps Distance Matrix API

Email Notifications: smtplib python

Infrastructure: Terraform provisioned AWS resources, i.e step functions, api gateway, lambda, roles, dynamodb,

State Management: AWS Step Functions

### Live Demo
Coming soon 

### Architecture Diagram
Coming soon 

Future Improvements for Production
Add user authentication and history of reminders

SMS support via Twilio

React frontend with validation and autocomplete

Better UI/UX design

Optimize for mobile devices

Integrate with a calendar system or create a feature that is a calendar system
