output "resource_server_scope_identifiers" {
  description = "Les identifiants des scopes du serveur de ressources pour cette version d'API"
  value       = aws_cognito_resource_server.this.scope_identifiers
}


output "api_gateway_rest_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_gateway_rest_stage_name" {
  value = aws_api_gateway_stage.this.stage_name
}

output "api_gateway_rest_domain" {
  value = aws_api_gateway_stage.this.invoke_url
}


output "aws_cognito_resource_server_scope_identifiers" {
  value = aws_cognito_resource_server.this.scope_identifiers
}
