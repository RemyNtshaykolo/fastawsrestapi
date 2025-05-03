help:
	@echo "\n🛠️  Available commands:\n"
	@echo "📦 Commands with a suffix like '-%' can be used with environments (e.g. dev, prod):"
	@echo "   Example: make deploy-dev or make tf-init-prod\n"
	@awk '\
		/^## / { \
			section=substr($$0, 4); \
			print "\n\033[1m" section "\033[0m"; \
		} \
		/^[a-zA-Z0-9\-_\.%]+:.*?#/ { \
			printf "  \033[36m%-30s\033[0m %s\n", $$1, substr($$0, index($$0,"#")+2) \
		} \
	' $(MAKEFILE_LIST)


## AWS
increase-lambda-quota-%: # 🚀 Increasing Lambda Quota
	@echo "\n========================================"
	@echo "🚀 INCREASING LAMBDA QUOTA"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && ./scripts/increase-lambda-quota.sh

lambda-%: # 🌐 Open AWS Lambda console URL in the default browser
	@source ./scripts/set-env.sh $* &&  uv run ./scripts/open-aws.py $* lambda

apigateway-%: # 🌐 Open AWS API Gateway console URL in the default browser
	@source ./scripts/set-env.sh $* &&  uv run ./scripts/open-aws.py $* apigateway

s3-%: # 🌐 Open AWS S3 console URL in the default browser
	@source ./scripts/set-env.sh $* &&  uv run ./scripts/open-aws.py $* s3

acm-%: # 🌐 Open AWS ACM console URL in the default browser
	@source ./scripts/set-env.sh $* &&  uv run ./scripts/open-aws.py $* acm

cloudfront-%: # 🌐 Open AWS CloudFront console URL in the default browser
	@source ./scripts/set-env.sh $* &&  uv run ./scripts/open-aws.py $* cloudfront



## LAMBDA
build-push-lambda-image-%: # 🐳 Build and push lambda image to ECR 
	@echo "\n========================================"
	@echo "🐳 BUILDING LAMBDA DOCKER IMAGE"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && ./scripts/build-push-lambda-image.sh $*

## TERRAFORM
tf-init-%: # 🔧 Initialize Terraform
	@echo "\n========================================"
	@echo "🔧 INITIALIZING TERRAFORM"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && terraform -chdir=.infra/terraform init

tf-plan-%: # 📋 Plan Terraform changes
	@echo "\n========================================"
	@echo "📋 PLANNING TERRAFORM CHANGES"
	@echo "========================================\n" 
	@source ./scripts/set-env.sh $* && ./scripts/tf-action.sh $* plan

tf-apply-ecr-%: # 🚀 Apply Terraform only for ECR
	@echo "🚀 APPLYING TERRAFORM CHANGES FOR ECR"
	@source ./scripts/set-env.sh $* && ./scripts/tf-action.sh $* apply-ecr

tf-apply-%: # 🚀 Apply Terraform changes
	@echo "\n========================================"
	@echo "🚀 APPLYING TERRAFORM CHANGES"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && ./scripts/tf-action.sh $* apply




tf-destroy-%: # 🗑️ Destroy Terraform resources
	@echo "\n========================================"
	@echo "🗑️  DESTROYING TERRAFORM RESOURCES"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && ./scripts/tf-action.sh $* destroy

## FASTAPI
new-version: # 📦 Create a new API version
	@echo "\n========================================"
	@echo "📦 CREATING NEW API VERSION"
	@echo "========================================\n"
	@uv run ./scripts/doc-new-version.py

fastapi-%: # 🚀 Running FastAPI server
	@echo "\n========================================"
	@echo "🚀 RUNNING FASTAPI SERVER"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && ./scripts/run-fastapi.sh 

## DOCUMENTATION
doc-%: # 📚 Build push docuentation and generate clients
	@echo "\n========================================"
	@echo "📚 GENERATING COMPLETE DOCUMENTATION"
	@echo "========================================\n"
	@make generate-openapi-files-$*
	@make upload-openapi-files-to-s3-$*
	@make build-swagger-ui-$*
	@make publish-doc-$*

generate-openapi-files-%: # 📝 Generate OpenAPI files for each version
	@echo "\n========================================"
	@echo "📝 GENERATING OPENAPI FILES"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && uv run ./scripts/generate-openapi-files.py

upload-openapi-files-to-s3-%: # 📤 Upload OpenAPI files to S3
	@echo "\n========================================"
	@echo "☁️  UPLOADING OPENAPI FILES TO S3"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && uv run ./scripts/upload-openapi-files-to-s3.py

build-swagger-ui-%: # 🎨 Build Api Documentation Swagger UI
	@echo "\n========================================"
	@echo "🎨 BUILDING SWAGGER UI"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && npx webpack --mode production  --output-path .swagger-ui

publish-doc-%: # 📤 Publish Documentation
	@echo "\n========================================"
	@echo "📤 PUBLISHING DOCUMENTATION"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && ./scripts/publish-doc.sh

ts-client: # 📚 Generate TypeScript client
	@echo "\n========================================"
	@echo "📚 GENERATING TS CLIENT"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && ./scripts/generate-api-clients.sh


## DEPLOYMENT
deploy-%: # ✨ Build lambda image, deploy api and host documentation on s3
	@echo "\n========================================"
	@echo "🚀 STARTING DEPLOYMENT"
	@echo "========================================\n"
	@make build-push-lambda-image-$*
	@make generate-openapi-files-$*
	@make tf-apply-$*
	@make doc-$*

info-%: # 📚 Display links from STAGE-output.json file
	@echo "\n========================================"
	@echo "📚 DISPLAYING LINKS FROM STAGE-output.json FILE"
	@echo "========================================\n"
	@source ./scripts/set-env.sh $* && uv run ./scripts/info.py $*


