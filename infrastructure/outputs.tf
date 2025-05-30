output "api_url" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}/"
}

output "sns_arn" {
  value = "${aws_sns_topic.user_updates.arn}"
  
}