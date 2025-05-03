# ===========================
# NOTE - API Gateway
# ===========================
locals {
  raw_openapi = jsondecode(file(var.doc_path))

  openapi = jsondecode(templatefile(var.doc_path, {
    cognito_user_pool_arn = var.cognito_user_pool.arn
    shared_lambda_arn     = aws_lambda_function.shared.invoke_arn
  }))


  resource_server = merge(
    { for item in flatten([
      for path, methods in local.openapi.paths : [
        for method, details in methods : [
          for security in try(details.security, []) : [
            for key, scopes in security : [
              for scope in scopes : {
                name  = "${replace(scope, "/", "-")}-${var.stage}"
                scope = scope
              }
            ] if key == "Oauth2ClientCredentials"
          ]
        ]
      ]
      ]) : replace(item.scope, "/", "-") => item
    },
    {
      "default.scope" = {
        name  = "default-${var.stage}"
        scope = "default.scope"
      }
    }
  )

  method_settings = flatten([
    for path, methods in local.raw_openapi.paths : [
      for method, details in methods : {
        path   = replace(path, "/", "")
        method = method
        settings = {
          throttling_burst_limit     = try(details["x-conf"]["throttling"]["burstLimit"], -1)
          throttling_rate_limit      = try(details["x-conf"]["throttling"]["rateLimit"], -1)
          caching_enabled            = try(details["x-conf"]["caching"]["enabled"], false)
          caching_max_ttl_in_seconds = try(details["x-conf"]["caching"]["maxTtl"], 3600)
        }
      }
    ]
  ])

  body = merge(local.openapi, {
    info = merge(local.openapi.info, {
      name = "${local.resource-prefix}-${var.api_version}"
    })
  })

}

data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "this" {
  body = jsonencode(local.body)
  name = "${var.stage}-${var.app_name}-${var.api_version}"
  tags = merge(
    var.default_tags,
    {
      # Name    = local.resource-prefix
      Version = var.api_version
    }
  )
}



resource "aws_api_gateway_gateway_response" "test" {
  for_each = {
    "4XX" = "DEFAULT_4XX"
    "5XX" = "DEFAULT_5XX"
  }
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = each.value
  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'*'"
  }
}


# ===========================
# NOTE - API Gateway Deployment
# ===========================
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    # Recréer le déploiement uniquement si le body change réellement
    redeployment = sha1(jsonencode(merge(local.body, {
      info = merge(local.openapi.info, {
        version = timestamp() # Forcer un nouveau déploiement à chaque apply
      })
    })))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ===========================
# NOTE - Role to allow API Gateway to write logs
# ===========================
resource "aws_iam_role" "api_gateway" {
  name = "${local.resource-prefix}-api-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}



resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api_gateway.arn
}
# ===========================
# NOTE - Cloudwatch Log Group
# ===========================
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/api-gateway/${local.resource-prefix}"
  retention_in_days = 1

  tags = merge(
    var.default_tags,
    {
      Name = "${local.resource-prefix}-api-logs"
    }
  )
}

# ===========================
# NOTE - API Gateway Stage
# ===========================
resource "aws_api_gateway_stage" "this" {
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.this.arn
    format = jsonencode({
      requestId  = "$context.requestId",
      ip         = "$context.identity.sourceIp",
      request    = "$context.requestTime",
      method     = "$context.httpMethod",
      path       = "$context.resourcePath",
      status     = "$context.status",
      response   = "$context.responseLength",
      user       = "$context.identity.user",
      user_agent = "$context.identity.userAgent",
    })
  }
  deployment_id         = aws_api_gateway_deployment.this.id
  rest_api_id           = aws_api_gateway_rest_api.this.id
  cache_cluster_enabled = local.openapi.x-cache.enabled
  cache_cluster_size    = local.openapi.x-cache.size
  stage_name            = "default"
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.default_tags,
    {
      Name = "${local.resource-prefix}-api-stage"
    }
  )
}

#

# ===========================
# NOTE - API Gateway stage domain mapping
# ===========================
resource "aws_api_gateway_base_path_mapping" "this" {
  count       = var.use_custom_domain ? 1 : 0
  domain_name = var.domain_name
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  base_path   = var.api_version
}

# ===========================
# NOTE - API Gateway Method Settings
# ===========================
resource "aws_api_gateway_method_settings" "this" {
  for_each = { for idx, method_setting in local.method_settings : idx => method_setting }

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "${each.value.path}/${upper(each.value.method)}"
  settings {
    throttling_burst_limit = each.value.settings.throttling_burst_limit
    throttling_rate_limit  = each.value.settings.throttling_rate_limit
    caching_enabled        = each.value.settings.caching_enabled
    cache_ttl_in_seconds   = each.value.settings.caching_max_ttl_in_seconds
  }
}
