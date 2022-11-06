/*
  aws region var
*/
variable "region" {
  description = "The region in which to deploy"
  type        = string
  default     = "us-east-1"
}

/*
  localstack var
*/
variable "use_localstack" {
  description = "Boolean whether or not to use localstack"
  type        = bool
  default     = true
}

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
