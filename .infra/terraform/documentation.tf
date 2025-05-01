module "this" {
  source = "./modules/website"
  providers = {
    aws.acm_provider = aws.acm_provider
  }
  stage    = var.stage
  app_name = var.app_name
  # Ajout des tags par défaut
  default_tags = {
    Stage   = var.stage
    Project = var.app_name
  }
}
