

resource "aws_dynamodb_table" "google-project-table" {
  name           = "google-project-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = "destination_name"

  attribute {
    name = "user_id"
    type = "N"
  }

  attribute {
    name = "destination_name"
    type = "S"
  }

  # attribute {
  #   name = "arrival_time"
  #   type = "S"
  # }
  # attribute {
  #   name = "is_one_time"
  #   type = "N"
  # }

  # attribute {
  #   name = "arrival_datetime"
  #   type = "S"
  # }

  # attribute {
  #   name = "origin_address"
  #   type = "S"
  # }
  # attribute {
  #   name = "destination_address"
  #   type = "S"
  # }
  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

 

  tags = {
    Name        = "google-project-table"
    Environment = "dev"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "dynamo_db_policy" {
  name ="dynamo-db-put-policy"
   policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem"
        ],
        Resource = aws_dynamodb_table.google-project-table.arn
      }
    ]
  })

}



resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "attach_putitem_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamo_db_policy.arn
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "google-api-lambda-function"
  handler       = "google-api-lambda-function.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "MyHTTPAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.my_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

