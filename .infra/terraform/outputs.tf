output "cognito_user_pool_domain_url" {
  value = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "api_gateway_urls" {
  description = "Map des URLs de l'API Gateway pour chaque version"
  value = {
    for version, api in module.api_rest : version => api.api_gateway_rest_domain
  }
}

output "api_documentation_bucket_name" {
  value = module.this.bucket_name
}
output "api_documentation_url" {
  value = "https://${module.this.bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
}

output "aws_region" {
  value = var.aws_region
}

