<!-- Logo et Titre centré -->
<p align="center">
  <img src="src/api/doc/logo.png" alt="logo" width="200" />
</p>

<h2 align="center">FastAPI to AWS API Gateway (REST) Boilerplate</h2>

<p align="center">
  Deploy your FastAPI app on AWS API Gateway REST using Terraform + OpenAPI.<br>
  Includes hosted Swagger UI on S3 with custom domains and versioning.
</p>

---

## 🚀 Introduction

This boilerplate lets you deploy versioned FastAPI applications on AWS API Gateway (REST) with:

- OAuth2 & API Keys  
- Throttling & burst limits  
- Response caching  
- Custom domain names  
- Hosted Swagger UI for each version

It **automatically transforms** the default OpenAPI schema from FastAPI by injecting AWS-specific extensions — no manual editing needed.

---

## ✨ Features

- 🔐 **Auth & Usage Plans** – OAuth2, API Keys, Usage Plans  
- 🚦 **Traffic Control** – Throttling and burst settings  
- ⚡ **Response Caching** – Low latency, faster APIs  
- 📚 **Multi-Version Docs** – Swagger UI hosted per version (on S3)  
- 🌐 **Custom Domains** – Subdomain config per environment

---

## 🧰 Prerequisites

Install:

- [Terraform](https://developer.hashicorp.com/terraform)
- [UV](https://docs.astral.sh/uv/getting-started/installation/)
- [Docker](https://www.docker.com/)
- [Node.js](https://nodejs.org/)

---

## ⚙️ Quickstart — Deploy in < 5 Minutes

### 1. 🔍 List Available Commands

```bash
make help
```

All commands follow this format: `make <command>-<stage>`  
_Example_: `make deploy-dev`

---

### 2. 📦 Install Python Dependencies

```bash
uv venv .venv
uv sync
```

---

### 3. 🔧 Configure AWS

Edit `config.py`:

```python
"aws_region": "eu-west-3",
"aws_accounts": {
    "dev": {
        "aws_account": "408566731358",
        "profile": "fast-rest-api",
        "live": False
    },
}
```

Custom domain behavior:

| Stage | API URL                       | Docs URL                          |
|-------|-------------------------------|------------------------------------|
| dev   | `api.dev.fastawsrestpi.com`   | `doc.api.dev.fastawsrestpi.com`   |
| prod  | `api.fastawsrestpi.com`       | `doc.api.fastawsrestpi.com`       |

---

## 🛠️ Deployment Steps

### ✅ 1. Init Terraform

```bash
make tf-init-dev
```

> Initializes Terraform, downloads providers, sets up local state.  
> You can configure any backend (S3, Terraform Cloud...) in `version.tf`.

---

### 🧪 2. Create the ECR Repository

```bash
make tf-ecr-dev
```

> Creates an AWS ECR repository for the Lambda Docker image.

---

### 🐳 3. Build & Push Lambda Image

```bash
make build-push-lambda-image-dev
```

> Builds and pushes your FastAPI Docker image to ECR.  
Includes lifecycle policy to remove untagged images.

---

### 📄 4. Generate OpenAPI Files

```bash
make generate-openapi-files-dev
```

Generates two files per API version:

- `openapi-v1-terraform.json` → used by AWS Gateway  
- `openapi-v1-swagger.json` → used for Swagger UI on S3

---

### 🚀 5. Full Deployment

```bash
make deploy-dev
```

> Runs:
- Docker build + push  
- Terraform apply  
- Swagger docs upload to S3

---

## 📁 Project Structure

```txt
.
├── src/
│   └── api/
│       ├── doc/                  # Swagger UI assets
│       └── versions/
│           └── v1/              # API code per version
├── .infra/
│   └── terraform/               # Terraform (Gateway, Lambda, S3, etc.)
├── config.py                    # Stage/account settings
├── Makefile                     # Automation commands
└── README.md
```

---

## 🧪 Example Make Commands

```bash
make tf-init-dev
make tf-ecr-dev
make build-push-lambda-image-dev
make generate-openapi-files-dev
make deploy-dev
```

---

## 🧑‍💻 Contributing

Open issues or PRs — feedback is welcome!

---

## 📜 License

MIT License