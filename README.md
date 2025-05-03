<div style="text-align: center;">
  <img src="src/api/doc/logo.png" alt="logo">
</div>

> Deploy your FastAPI application on Amazon API Gateway's REST service using Terraform and an OpenAPI specification.
> It also provides the necessary Terraform code to host your auto-generated API documentation (Swagger UI) on an S3 website, with optional support for custom domains.



## Introduction

This repository provides everything you need to deploy and manage multiple versions of your FastAPI application on AWS API Gateway (REST) — while taking full advantage of its enterprise-grade capabilities.

FastAPI generates a standard OpenAPI schema by default, but AWS API Gateway requires specific x-amazon-apigateway-* extensions to enable advanced features like custom authorization flows, method-level caching, and throttling policies.
Manually editing these configurations is tedious and error-prone.

This boilerplate automates the process by overriding and enriching the FastAPI-generated OpenAPI documentation, making your APIs instantly ready for production deployment on AWS — with all the advanced settings already in place.

## ✅ Key Features
-	🔐 Authentication & Authorization
Native support for OAuth2, API Keys, and Usage Plans.
-	🚦 Traffic Control
Fine-tuned throttling and burst limits to protect your backend.
- ⚡ Response Caching
Improve performance and reduce latency with built-in caching.

📚 Multi-Version Documentation Included

Easily generate and deploy branded, versioned Swagger documentation — hosted on an S3 static website, ready to share with your team or stakeholders.

⸻

Souhaites-tu une version en français également ?
## Prerequisites

- Terraform installed
- UV installed
  - [Installation Guide](https://docs.astral.sh/uv/getting-started/installation/)
- Docker installed
- Node.js installed

## Launching Your First API in Less Than 5 Minutes

First, with `make help`, you will get a list of all available commands. All the make commands are parameterized as `command-stage_name`.

### Install dependencies

- Create a virtual env : `uv venv .venv`
- Install dependencies : `uv sync`

### Set up your documentation logo

- src/api/doc/icon.png : favicon
- src/api/doc/logo.png : Navbar icon

### Set Up Your AWS Account and Region
In `config.py`, fill in your dev AWS account and aws region.

```python
  "aws_region": "eu-west-3", # Your region
    "aws_accounts": {
        "dev": {
            "aws_account": "408566731358", # Your aws accound ID
            "profile": "fast-rest-api", # The aws profile you set for this account in your .aws/credentials file.
            "live":False
        },
    },
```
Latter on, you will be able to declared multiple stages (dev, staging, prod, etc.). The `live` parameter is mainly used for custom domain name configuration.

For non-live environments, such as dev, the stage name is include in the urls:
`api.dev.fastawsrestpi.com` : custom domain name for your api.
`doc.api.dev.fastawsrestpi.com` : custome domain name for your api documentation.

For your live environment, such as prod, the stage name is not included
`api.fastawsrestpi.com`
`doc.api.fastawsrestpi.com`

### Deploy

In the following paragraph a `dev` environment was declared in the `config.py` configuration file. Thus all the following make command will use the `-dev`.
Example : `make tf-init-%` becomes `make tf-init-dev`

#### Initialise your terraform

Use the command `make tf-init-dev` to intialise your terraform workform.

Details:

> This command downloads the aws providers and the required modules in the `.infra/.terraform` folder.
> it also create local folder `.infra/terraform/terraform.tfstate.d/dev` where the terraform state will be stored. However you can use whatever terraform backend to store your terraform state `s3`, `terraform cloud`... This can be specified in the `version.tf` folder.

#### Create the ECR repository

Before to build and push the docker image for the lambda. We first need to create an ECR repository where the lambda image will be pushed.
Use the command `make tf-ecr-dev`. It will apply the terraform configuration but only for the resources `aws_ecr_repository` in the `.infra/terraform/ecr.tf` file.

#### Build and push the lambda docker image.

Use the command `make build-push-lambda-image-dev` to build and push the lambda docker image to the previously created ECR repository.

Details:

> This commands build your docker image using the `Dockerfile`. It was found (https://docs.astral.sh/uv/guides/integration/aws-lambda/#deploying-a-docker-image:~:text=other%20unnecessary%20files.-,Dockerfile,-FROM%20ghcr.io)[here]
>
> Note that a `aws_ecr_lifecycle_policy` exists, this is usefull in order to automatically remove untagged image.

- The `aws_api_gateway_rest_api` terraform resource can leverage an openapi file in order to create in an api with its differents settings.

The api source code is in the folder `src/api/`. For each version of your api a subfolder exsit in the `src/api/versions`. In the initial version of this boilerplate only one version exists v1.
Use the command `make generate-openapi-files-dev` to generate the openapi for each version of your api. Two files are created for each versions

- `openapi-<version>-terraform.json`
- `openapi-<version>-swagger.json`

- Build and push the lambda docker image on the ECR
- Apply terraform
- Build and push documentation
  `make deploy-dev`
