# ACM certificate for the API domain name
resource "aws_acm_certificate" "api" {
  domain_name       = local.api_domain_name
  validation_method = "DNS"

  tags = {
    Name    = "${var.stage}-${var.app_name}-api-certificate"
    Stage   = var.stage
    Project = var.app_name
  }
}

# Api Gateway custom domain name
resource "aws_api_gateway_domain_name" "this" {
  count                    = var.use_custom_domain ? 1 : 0
  domain_name              = local.api_domain_name
  regional_certificate_arn = aws_acm_certificate.api.arn


  tags = {
    Name    = "${var.stage}-${var.app_name}-api-domain"
    Stage   = var.stage
    Project = var.app_name
  }
}

module "api_rest" {
  for_each = var.api_versions
  source   = "./modules/api"
  providers = {
    aws.acm_provider = aws.acm_provider
  }
  use_custom_domain   = var.use_custom_domain
  api_description     = "${var.app_name} ${each.value} API"
  app_name            = var.app_name
  stage               = var.stage
  domain_name         = local.api_domain_name
  lambda_handler      = "api.versions.${each.value}.app.lambda_handler"
  doc_path            = "../../src/api/versions/${each.value}/openapi-${each.value}-terraform.json"
  api_version         = each.value
  ecr_repository_url  = aws_ecr_repository.this.repository_url
  lambda_image_digest = data.aws_ecr_image.lambda_image.image_digest
  lambda_image_id     = data.aws_ecr_image.lambda_image.id
  lambda_env_variables = {
    STAGE            = var.stage
    COGNITO_ENDPOINT = "${local.cognito_user_pool_domain_url}/oauth2/token"
    MY_NAME          = "Fast REST API"
  }
  # lambda_subnet_ids         = data.terraform_remote_state.infra.outputs.lambda_subnets[*].id
  # lambda_security_group_ids = data.terraform_remote_state.infra.outputs.lambda_sg[*].id
  # Ajout des tags par défaut avec la version API
  default_tags = merge(local.tags, {
    ApiVersion = each.value
  })
  cognito_user_pool = aws_cognito_user_pool.this
}
