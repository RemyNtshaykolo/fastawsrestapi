<div style="text-align: center;">
  <img src="src/api/doc/logo.png" alt="logo">
</div>


Deploy your FastAPI application on AWS API Gateway (REST) using Terraform and OpenAPI.
This boilerplate also hosts versioned Swagger UI docs on an S3 static website with optional custom domains.

⸻

🚀 Introduction

This repository provides everything you need to deploy and manage multi-version FastAPI apps on AWS API Gateway (REST), with full support for enterprise features like:
	•	OAuth2 & API Keys
	•	Throttling & burst control
	•	Response caching
	•	Custom domain names
	•	Hosted Swagger UI per version

Instead of manually editing x-amazon-apigateway-* extensions in OpenAPI, this boilerplate automates the process, transforming your FastAPI schema into a production-ready API config.

⸻

✨ Features
	•	🔐 Authentication & Authorization: OAuth2, API Keys, Usage Plans
	•	🚦 Traffic Control: Fine-tuned throttling and burst limits
	•	⚡ Response Caching: Reduce latency & boost performance
	•	📚 Multi-Version Docs: Hosted Swagger UI for each version, branded and deployed on S3
	•	🌐 Custom Domains: Easily configure subdomains per environment

⸻

🧰 Prerequisites

Make sure the following tools are installed:
	•	Terraform
	•	UV
	•	Docker
	•	Node.js

⸻

⚙️ Quickstart — Deploy in < 5 min

1. 🔍 Explore Available Commands

make help

All commands follow this structure: make <action>-<stage> (e.g. make deploy-dev).

⸻

2. 📦 Install Python Dependencies

uv venv .venv
uv sync



⸻

3. 🔧 Configure AWS Access

Edit config.py:

"aws_region": "eu-west-3",
"aws_accounts": {
    "dev": {
        "aws_account": "408566731358",
        "profile": "fast-rest-api",
        "live": False
    },
}

This allows domain differentiation:

Environment	API URL	Docs URL
dev	api.dev.fastawsrestpi.com	doc.api.dev.fastawsrestpi.com
prod	api.fastawsrestpi.com	doc.api.fastawsrestpi.com



⸻

🛠️ Deployment Steps

✅ 1. Init Terraform

make tf-init-dev

Initializes Terraform, installs providers, and sets up the state folder.
You can use any backend (S3, Terraform Cloud…) by editing version.tf.

⸻

🧪 2. Create the ECR Repository

make tf-ecr-dev

Creates only the aws_ecr_repository used by the Lambda Docker image.

⸻

🐳 3. Build & Push Lambda Docker Image

make build-push-lambda-image-dev

Uses the provided Dockerfile to build your API image and push to ECR.
Includes lifecycle policy to clean up untagged images.

⸻

📄 4. Generate OpenAPI Files

make generate-openapi-files-dev

For each version (src/api/versions/v1/), two files are generated:

	•	openapi-v1-terraform.json (for AWS Gateway)
	•	openapi-v1-swagger.json (for Swagger UI)

⸻

🚀 5. Deploy Everything

make deploy-dev

Performs all steps:

	•	Build + push Lambda image
	•	Apply Terraform
	•	Upload Swagger UI docs to S3

⸻

