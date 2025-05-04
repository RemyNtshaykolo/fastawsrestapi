module "this" {
  source = "./modules/website"
  providers = {
    aws.acm_provider = aws.acm_provider
  }
  stage             = var.stage
  app_name          = var.app_name
  description       = "This is the api documentation for the ${var.app_name} application"
  use_custom_domain = var.use_custom_domain_for_documentation
  domain_name       = local.api_doc_domain_name
  default_tags = {
    Stage   = var.stage
    Project = var.app_name
  }
}
