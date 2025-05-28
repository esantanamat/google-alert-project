
variable "region" {
  description = "AWS resources region"
  type = string
  default = "us-east-1"
}

variable "environment" {
  description = "AWS resources environment"
  type = string
  default = "test"
}

variable "lambda_s3_bucket" {
  description = "Lambda s3 bucket for tf github actions"
  type = string
  default = "amzn-s3-dev-bucket-es12452"
}
