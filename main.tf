provider "aws" {
  region = "us-east-1"
}

locals {
  timestamp           = timestamp()
  timestamp_sanitized = replace("${local.timestamp}", "/[-| |T|Z|:]/", "")
  lambda_zip_name     = "${var.lambda_name}-${local.timestamp_sanitized}.zip"
}

resource "aws_s3_bucket" "this" {
  bucket        = lower(var.artifacts_bucket_name)
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = var.acl
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = file("lambda-role.json")
}

data "template_file" "lambda_policy" {
  template = file("lambda-policy.json")

  vars = {
    bucket_arn = aws_s3_bucket.this.arn
  }
}

resource "aws_iam_policy" "this" {
  name   = var.policy_name
  policy = data.template_file.lambda_policy.rendered
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "null_resource" "pip_install" {
  triggers = {
    always_run = local.timestamp
  }

  provisioner "local-exec" {
    command = "pip3 install -r src/requirements.txt -t src/"
  }
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "src/"
  output_path = local.lambda_zip_name
  excludes = [
    "__pycache__",
    "src/__pycache__",
    "test",
    "tests"
  ]

  depends_on = [
    null_resource.pip_install
  ]
}

resource "aws_s3_object" "this" {
  bucket = lower(var.artifacts_bucket_name)
  key    = local.lambda_zip_name
  source = data.archive_file.this.output_path

  depends_on = [
    data.archive_file.this
  ]
}

resource "aws_lambda_function" "this" {
  function_name    = var.lambda_name
  runtime          = var.lambda_runtime
  s3_bucket        = lower(var.artifacts_bucket_name)
  s3_key           = aws_s3_object.this.key
  role             = aws_iam_role.this.arn
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.this.output_base64sha256

  depends_on = [
    aws_s3_object.this
  ]
}