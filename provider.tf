provider "aws" {
  region     = var.region
  access_key = var.use_localstack ? "fake_access_key" : null
  secret_key = var.use_localstack ? "fake_secret_key" : null

  s3_use_path_style           = var.use_localstack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      apigateway     = "http://localstack:4566"
      cloudformation = "http://localstack:4566"
      cloudwatch     = "http://localstack:4566"
      dynamodb       = "http://localstack:4566"
      es             = "http://localstack:4566"
      firehose       = "http://localstack:4566"
      iam            = "http://localstack:4566"
      kinesis        = "http://localstack:4566"
      lambda         = "http://localstack:4566"
      route53        = "http://localstack:4566"
      redshift       = "http://localstack:4566"
      s3             = "http://localstack:4566"
      secretsmanager = "http://localstack:4566"
      ses            = "http://localstack:4566"
      sns            = "http://localstack:4566"
      sqs            = "http://localstack:4566"
      ssm            = "http://localstack:4566"
      stepfunctions  = "http://localstack:4566"
      sts            = "http://localstack:4566"
    }
  }
}