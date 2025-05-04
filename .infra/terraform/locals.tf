locals {
  api_domain_name              = "api${var.live_environment ? "" : ".${var.stage}"}.${var.domain_name}" # For dev stage: api.dev,  For prod stage: api
  api_doc_domain_name          = "doc.api${var.live_environment ? "" : ".${var.stage}"}.${var.domain_name}"
  dashboard_domain_name        = "dashboard${var.live_environment ? "" : ".${var.stage}"}.${var.domain_name}"
  prefix                       = "${var.stage}-${var.app_name}"
  cognito_user_pool_domain_url = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.aws_region}.amazoncognito.com"
  tags = {
    Project = var.app_name
    Stage   = var.stage
  }
}
