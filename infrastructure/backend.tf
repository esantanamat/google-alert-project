
terraform {
  backend "s3" {
    bucket         = "amzn-s3-dev-bucket-es12452"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
