# example-tf-aws-lambda
An example of using Terraform to deploy a Python lambda to AWS

## Overview
This is a simple example of using Terraform to deploy a Python (v3.8) Lambda to AWS. It provisions:
- the necessary IAM policy/role for the Lambba
- the Lambda itself named, `ExampleTfAWSLambda`

The Lambda makes a simple call to `https://randomuser.me/api` to fetch random user information and prints the output to Cloudwatch.

> Note: there is a 50MB limit on uploading the packaged zip to AWS. If the package exceeds this limit, you'll have to first send it to an AWS S3 bucket and rework the contents of `main.tf`.

## Requirements
At minimum, these are the tools you'll need to have installed:
- Docker
- [Terraform](https://www.terraform.io/downloads). [TFSwith](https://tfswitch.warrensbox.com/) is a *very* handy tool when you're dealing with multiple codebases with different versions of Terraform; _choose one or the other_
- Python > v3.7
  - [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  - [LocalStack AWS CLI](https://docs.localstack.cloud/integrations/aws-cli/#localstack-aws-cli-awslocal)

If you actually want to deploy this to AWS you'll need an account and have it [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

## Local development
### Docker
Initially, one would start building out the Lambda using the Dockerfile within this repo. It:
- is based on Python v3.8
- installs updates and various tools (ex: jq, wget, curl, etc)
- creates a non-root user and switches to said non-root user for security

To build it, run the command below which creates an image called `example-lambda:latest`.

`docker build --no-cache -t example-lambda .`

Once built, run the image and mount the current working directory:

`docker run -it --rm -v $(pwd):/home/worker example-lambda:latest bash`

From here, install the dependencies and add anything else you may want.

**However**, for the sake of this example, we'll omit the creation of the Docker image and run [LocalStack](https://localstack.cloud/) instead.

### LocalStack
Launch LocalStack by running `docker compose up` within this repository.

Review the corresponding subheading depending upon what you installed whether it be Terraform or TFSwitch.

#### Terraform
Run the following to initialize everything: `terraform init`.

Run `terraform validate` to validate the Terraform configrations.

Run `terraform plan` "which lets you preview the changes that Terraform plans to make to your infrastructure".

Run `terraform apply` to execute the Terraform configurations; enter `yes` to confirm.

##### TFSwitch
Run `tfswitch` to switch to the version specified within `versions.tf`.

Run the following to initialize everything: `terraform init`.

Run `terraform validate` to validate the Terraform configrations.

Run `terraform plan` "which lets you preview the changes that Terraform plans to make to your infrastructure".

Run `terraform apply` to execute the Terraform configurations; enter `yes` to confirm.

#### aws/awslocal CLI
With the Lambda deployed to LocalStack, you must now `invoke` it via the CLI as there is no freely available UI utility.

To interact with LocalStack via the CLI, simply append `local` to the `aws` CLI command and include the endpoint. For example, to view the list of S3 buckets in LocalStack, run `awslocal --endpoint-url=http://localstack:4566 s3 ls`; there shouldn't be any.

To invoke the Lambda, run `awslocal --endpoint-url=http://localstack:4566 lambda invoke --function-name ExampleTfAWSLambda response.json`.

The Lambda prints the randomly returned user to CloudWatch. To view the data, run:

```bash
awslocal --endpoint-url=http://localstack:4566 logs get-log-events --log-group-name /aws/lambda/ExampleTfAWSLambda --log-stream-name $(awslocal --endpoint-url=http://localstack:4566 logs describe-log-streams --log-group-name /aws/lambda/ExampleTfAWSLambda --order-by LastEventTime --query logStreams[].logStreamName --max-items 1 --descending --output text | head -n 1)
````

#### Tear down
Tear down what was provisioned in LocalStack via Terraform by running: `terraform destroy`; enter `yes` to confirm.

Tear down LocalStack itself by running `docker compose down -v`.

## Deploy to AWS
If you've [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) the AWS CLI, to deploy the Lambda to AWS run:
```bash
terraform init
terraform validate
terraform plan -var "use_localstack=false"
```

`use_localstack` is a variable declared in `variables.tf` and its default value is set to `true`. Since we want to actually deploy this to AWS and not LocalStack, we're overriding it.

Run `terraform apply -var "use_localstack=false"` to deploy the Lambda to AWS; enter `yes` to confirm.

You have two ways to invoke the Lambda deployed to AWS:
- CLI. Run: 

`aws lambda invoke --function-name ExampleTfAWSLambda response.json`
- AWS Console. Go to:
  - Lambda
  - Click on the function name, `ExampleTfAWSLambda`
  - Click on the `Test` tab
  - Click on the orange `Test` button
  
You have two ways to view the contents of what was sent to CloudWatch:
- CLI. Run:

```bash
aws logs get-log-events --log-group-name /aws/lambda/ExampleTfAWSLambda --log-stream-name $(aws logs describe-log-streams --log-group-name /aws/lambda/ExampleTfAWSLambda --order-by LastEventTime --query logStreams[].logStreamName --max-items 1 --descending --output text | head -n 1)
````
- AWS Console. Go to:
  - CloudWatch
  - Expand `Logs` on the left
  - Click on `Log Groups`
  - Click on the Log Group, `/aws/lambda/ExampleTfAWSLambda`
  - Click on the Log stream

To tear everything down, simply run `terraform destroy -var "use_localstack=false"`; enter `yes` to confirm.
