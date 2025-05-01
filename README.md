## Welcome

Welcome to the Fast REST API. The purpose of this repository is to enable you to easily deploy your FastAPI on Amazon's API Gateway REST service and leverage its features such as throttling, burst, caching, and authentication with API key or OAuth2 and to provide a branded swagger documentation

## Prerequisites

- Terraform installed
- UV installed
  - [Installation Guide](https://docs.astral.sh/uv/getting-started/installation/)
- Docker installed
- Node.js installed

## Launching Your First API in Less Than 5 Minutes

First, with `make help`, you will get a list of all available commands. All the make commands are parameterized as `command-stage_name`.

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

- Create the ECR repository:
  `make tf-ecr-dev`
- Build and push the lambda docker image on the ECR
- Apply terraform
- Build and push documentation
  `make deploy-dev`
