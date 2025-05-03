<div style="text-align: center;">
  <img src="src/api/doc/logo.png" alt="logo">
</div>

> Deploy your FastAPI application on Amazon API Gateway's REST service using Terraform and an OpenAPI specification.
> It also provides the necessary Terraform code to host your auto-generated API documentation (Swagger UI) on an S3 website, with optional support for custom domains.

---

## Why this repo exist

This repository provides everything you need to deploy several versions of your FastAPI application on AWS API Gateway REST and leverage its full capabilities:
• 🔐 Authorization (OAuth2) & Authentication (API Keys + Usage Plans)
• 🚦 Throttling & Burst Limits to control traffic
• ⚡ Caching for faster response times

It also includes everything required to generate and deploy Swagger documentation for multiple API versions — hosted on a branded S3 website.

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

### Set Up Your AWS Account

In `pyproject.toml`, fill in your AWS account and the associated AWS_PROFILE name:

```toml
[tool.infrastructure.aws_accounts.dev]
aws_account = "408566731358"
profile = "fast-rest-api" # This your aws credentials name
```

You can specify multiple stages (dev, staging, prod, etc.). The `live` parameter will be used to specify whether the stage should be included in the subdomain name.

For non-live environments, such as dev:
`doc.api.dev.fastapi.com`

For live environments:
`doc.api.fastapi.com`

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
