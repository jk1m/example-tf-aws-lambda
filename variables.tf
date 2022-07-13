/*
  iam vars
*/
variable "role_name" {
  description = "The name of the role"
  type        = string
  default     = "ExampleTfAWSLambdaRole"
}

variable "policy_name" {
  description = "The of the policy to attach to the role"
  type        = string
  default     = "ExampleTfAWSLambdaPolicy"
}

/*
 s3 bucket vars
*/
variable "force_destroy" {
  description = "Whether or not objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = true
}

variable "acl" {
  description = "The bucket ACl"
  type        = string
  default     = "private"
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies"
  type        = bool
  default     = true
}

/*
  lambda vars
*/
variable "lambda_name" {
  description = "The name of your lambda. This is taken from the github repo"
  type        = string
  default     = "ExampleTfAWSLambda"
}

variable "lambda_runtime" {
  description = "The runtime of the lambda"
  type        = string
  default     = "python3.8"
}

variable "lambda_handler" {
  description = "The name of the mehtod that processes events"
  type        = string
  default     = "lambda.handler"
}

variable "artifacts_bucket_name" {
  description = "The name of the lambda artifact bucket"
  type        = string
  default     = "ExampleTfAWSLambda-artifacts-bucket"
}
