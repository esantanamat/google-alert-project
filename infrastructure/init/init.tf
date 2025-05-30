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
  name ="dynamo-db-put-policy"
   policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",

        
    
        ],
        Resource = aws_dynamodb_table.google-project-table.arn
      }
    ]
  })

}
resource "aws_iam_policy" "dynamo_db_get_policy" {
  name ="dynamo-db-get-policy"
   policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",

        
    
        ],
        Resource = aws_dynamodb_table.google-project-table.arn
      }
    ]
  })

}

resource "aws_iam_policy" "ecr_policy" {
  name = "lambda-ecr-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "ecr:GetAuthorizationToken",
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




resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "reminder_lambda_basic_execution" {
  role       = aws_iam_role.reminder_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "attach_putitem_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamo_db_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_getitem_policy" {
  role       = aws_iam_role.reminder_exec.name
  policy_arn = aws_iam_policy.dynamo_db_get_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecr_policy_google_api_lambda" {
  role = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecr_policy_reminder_api_lambda" {
  role = aws_iam_role.reminder_exec.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}
resource "aws_ecr_repository" "lambda" {
  name = "google-lambda"
}
