terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_dynamodb_table" "google-project-table" {
  name           = "DestinationEntries"
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

  attribute {
    name = "arrival_time"
    type = "S"
  }
  attribute {
    name = "is_one_time"
    type = "N"
  }

  attribute {
    name = "arrival_datetime"
    type = "S"
  }

  attribute {
    name = "origin_address"
    type = "S"
  }
  attribute {
    name = "destination_address"
    type = "S"
  }
  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

 

  tags = {
    Name        = "google-project-table"
    Environment = "dev"
  }
}