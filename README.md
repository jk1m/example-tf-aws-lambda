# example-tf-aws-lambda
An example of using Terraform to deploy a Python lambda to AWS

## Overview
This is a simple example of using Terraform to deploy a Python (v3.8) lambda to AWS. It provisions:
- an S3 bucket to store the lambda artifact
- the necessary permissions for the lambda to run
- installs the Python requirements within the `src` folder
- the actual lambda

## Lambda
The lambda makes a simple call to `https://randomuser.me/api` to fetch random user information and prints the output to Cloudwatch.

## Docker
For local development:
- build the image
- run the container
- run lambda.py 

`docker build --no-cache -t example-lambda .`

`docker run -it --rm example-lambda:latest bash`

`python lambda.py`

## Deploy to AWS
> It is assumed you already have Terraform installed and your AWS credentials configured.

To deploy the lambda to AWS, run:
- `terraform init`
- `terraform validate`
- `terraform plan`

If there are no errors from any of the steps above, run the command below to deploy.

`terraform apply -auto-approve`

Invoke your lambda by:
- going to the AWS console
- click on the function name
- click on the `Test` tab under `Function overview`
- click on the `Test` button on the right

View the random user details by:
- going to CloudWatch
- in the left under `Logs`, click `Log groups`
- click on the log group corresponding to the function
- click on the log stream

When you're done, tear everything down by running:

`terraform destroy -auto-approve`

## Ending notes
As mentioned earlier, this is merely an example. There are several areas where improvements can be made such as:
- CI/CD
	- Unit tests
	- Code scanning
	- Versioning of releases
- Terraform modules
- Provision AWS IAM roles, policies outside of the lambda
- Provision AWS S3 bucket outside of the lambda

> The bucket is set to force destroy everything within it! This is just an example! Don't run this in production!