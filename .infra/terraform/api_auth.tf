# Collecte tous les scope_identifiers de toutes les versions d'API
locals {
  # Récupération de tous les scopes de toutes les versions d'API
  all_api_scopes = flatten([
    for version, api in module.api_rest : api.aws_cognito_resource_server_scope_identifiers
  ])

  all_api_keys = flatten([
    for plan_name, plan in var.usage_plans :
    [
      for api_key in plan.api_keys :
      {
        name       = "${local.prefix}-${api_key}"
        api_key    = api_key
        usage_plan = plan_name
      }
    ]
  ])

  all_api_keys_map = {
    for key in local.all_api_keys :
    "${key.usage_plan}-${key.api_key}" => key
  }
}

# COGNITO
resource "aws_cognito_user_pool" "this" {
  name = "${local.prefix}-pool"
  tags = local.tags
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = local.prefix
  user_pool_id = aws_cognito_user_pool.this.id
}


resource "aws_cognito_user_pool_client" "this" {
  for_each                             = var.oauth2_clients
  name                                 = "${local.prefix}-${each.key}"
  user_pool_id                         = aws_cognito_user_pool.this.id
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = local.all_api_scopes
  generate_secret                      = true
  access_token_validity                = 24 # 24 hours
}


# ===========================
# NOTE - API Gateway Usage Plan
# ===========================
resource "aws_api_gateway_usage_plan" "this" {
  for_each = var.usage_plans
  name     = "${local.prefix}-${each.key}"

  # Bloc dynamique pour créer un api_stages pour chaque version d'API
  dynamic "api_stages" {
    for_each = module.api_rest
    content {
      api_id = api_stages.value.api_gateway_rest_id
      stage  = api_stages.value.api_gateway_rest_stage_name

      # Section throttle (commentée mais corrigée)
      # dynamic "throttle" {
      #   for_each = local.method_settings
      #   content {
      #     burst_limit = throttle.value.settings.throttling_burst_limit
      #     rate_limit  = throttle.value.settings.throttling_rate_limit
      #     path        = "${throttle.value.path}/${upper(throttle.value.method)}"
      #   }
      # }
    }
  }

  quota_settings {
    limit  = each.value.limit
    offset = each.value.offset
    period = each.value.period
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-${each.key}-usage-plan"
    }
  )
}



# ===========================
# NOTE - API Gateway API Key
# ===========================
resource "aws_api_gateway_api_key" "this" {
  for_each = local.all_api_keys_map
  name     = each.value.name
  enabled  = true
  tags     = local.tags
}


# # ===========================
# # NOTE - API Gateway Usage Plan Key
# # ===========================
resource "aws_api_gateway_usage_plan_key" "this" {
  for_each      = local.all_api_keys_map
  key_id        = aws_api_gateway_api_key.this[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[each.value.usage_plan].id
}
