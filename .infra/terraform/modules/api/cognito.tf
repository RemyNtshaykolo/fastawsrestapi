resource "aws_cognito_resource_server" "this" {
  identifier = local.api-resource-server
  name       = "api"
  dynamic "scope" {
    for_each = local.resource_server
    content {
      scope_name        = scope.value.scope
      scope_description = "${scope.value.scope} route"
    }
  }
  user_pool_id = var.cognito_user_pool.id
}
