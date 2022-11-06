locals {
  timestamp           = timestamp()
  timestamp_sanitized = replace("${local.timestamp}", "/[-| |T|Z|:]/", "")
  lambda_zip_name     = "${var.lambda_name}-${local.timestamp_sanitized}.zip"
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = file("lambda-role.json")
}

resource "aws_iam_policy" "this" {
  name   = var.policy_name
  policy = file("lambda-policy.json")
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

resource "aws_lambda_function" "this" {
  function_name    = var.lambda_name
  filename         = local.lambda_zip_name
  runtime          = var.lambda_runtime
  role             = aws_iam_role.this.arn
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.this.output_base64sha256
}

resource "null_resource" "clean_package_folders" {
  triggers = {
    always_run = local.timestamp
  }

  provisioner "local-exec" {
    command = "find ./src -mindepth 1 -maxdepth 1 -type d ! -name 'test*' -exec rm -fr {} \\;"
  }

  depends_on = [
    aws_lambda_function.this
  ]
}

resource "null_resource" "clean_package_files" {
  triggers = {
    always_run = local.timestamp
  }

  provisioner "local-exec" {
    command = "find ./src -mindepth 1 -maxdepth 1 -type f ! -name 'lambda.py' ! -name 'requirements.txt' ! -name '.gitignore' -exec rm -f {} \\;"
  }

  depends_on = [
    null_resource.clean_package_folders
  ]
}

resource "null_resource" "clean_packaged_lambda" {
  triggers = {
    always_run = local.timestamp
  }

  provisioner "local-exec" {
    command = "find . -type f -name '*.zip' -exec rm -f {} \\;"
  }

  depends_on = [
    null_resource.clean_package_files
  ]
}