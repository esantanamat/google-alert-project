data "terraform_remote_state" "init" {
  backend = "s3"

  config = {
    bucket         = "amzn-s3-dev-bucket-es12452"
    key            = "init/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}


resource "aws_dynamodb_table" "google_project_table" {
  name         = "google-project-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "arrival_datetime"

  attribute {
    name = "user_id"
    type = "N"
  }

  # attribute {
  #   name = "destination_name"
  #   type = "S"
  # }

  # Uncomment attributes as needed for future features
  # attribute {
  #   name = "arrival_time"
  #   type = "S"
  # }
  attribute {
    name = "arrival_datetime"
    type = "S"
  }
  # attribute {
  #   name = "origin_address"
  #   type = "S"
  # }
  # attribute {
  #   name = "destination_address"
  #   type = "S"
  # }
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

resource "aws_iam_role" "reminder_exec" {
  name = "lambda_reminder_exec_role"

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
  name = "dynamo-db-put-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["dynamodb:PutItem"],
      Resource = aws_dynamodb_table.google_project_table.arn
    }]
  })
}

resource "aws_iam_policy" "dynamo_db_get_policy" {
  name = "dynamo-db-get-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["dynamodb:GetItem", "dynamodb:Scan"],
      Resource = aws_dynamodb_table.google_project_table.arn
    }]
  })
}

resource "aws_iam_policy" "ecr_policy" {
  name = "lambda-ecr-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ecr:GetAuthorizationToken",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "arn:aws:ecr:us-east-1:463470969308:repository/google-lambda"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_putitem_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamo_db_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_getitem_policy" {
  role       = aws_iam_role.reminder_exec.name
  policy_arn = aws_iam_policy.dynamo_db_get_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "reminder_lambda_basic_execution" {
  role       = aws_iam_role.reminder_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_ecr_policy_google_api_lambda" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecr_policy_reminder_api_lambda" {
  role       = aws_iam_role.reminder_exec.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}


resource "aws_lambda_function" "my_lambda" {
  function_name = "google-api-lambda-function"
  image_uri     = "${data.terraform_remote_state.init.outputs.ecr_repository_url}:http-handler-latest"
  package_type  = "Image"
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
}

resource "aws_lambda_function" "reminder_api_lambda" {
  function_name = "reminder-api-lambda-function"
  image_uri     = "${data.terraform_remote_state.init.outputs.ecr_repository_url}:reminder-checker-latest"
  package_type  = "Image"
  role          = aws_iam_role.reminder_exec.arn
  timeout       = 30
}


resource "aws_apigatewayv2_api" "http_api" {
  name          = "MyHTTPAPI"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["Content-Type"]
    allow_methods = ["POST", "OPTIONS"]
    allow_origins = [
      "https://enmanuel-s-test-bucket-125.s3.us-east-1.amazonaws.com",
       
    ]
  }
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


resource "aws_s3_bucket" "example" {
  bucket = "enmanuel-s-test-bucket-125"

  tags = {
    Name = "S3_Static_Website_Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.example.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }
}


resource "aws_sns_topic" "user_updates" {
  name = "arriveby-alert-sns"

  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}


#toggle this for pipeline trigger, dummy trigger
resource "null_resource" "dummy_trigger" {
  provisioner "local-exec" {
    command = "echo 'Triggered by dummy resource'"
  }
}
