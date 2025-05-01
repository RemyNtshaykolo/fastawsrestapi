locals {
  # Préfixe de base pour les ressources
  resource-prefix = "${var.stage}-${var.app_name}-${var.api_version}"

  # Noms de domaine et ressources
  api-resource-server = local.resource-prefix

  lambda-name   = local.resource-prefix
  lambda-prefix = local.resource-prefix


  # Configuration des lambdas
  lambdas_conf = merge([
    for path, pathMethods in local.openapi.paths : {
      for method, documentation in pathMethods :
      "${method}${path}" => {
        documentation : documentation,
        path : path,
      }
    }
  ]...)

  # Variables d'environnement requises
  required_env_vars = { for path, methods in local.openapi.paths :
    path => { for method, details in methods :
      method => try(details.openapi_extra["x-env-variables-required"], [])
    }
  }

  # Routes avec Lambda dédiée
  dedicated_lambda_routes = flatten([
    for path, methods in local.raw_openapi.paths : [
      for method, details in methods : {
        path   = path
        method = method
        config = details
      } if try(details.openapi_extra["x-dedicated-lambda"], false) == true
    ]
  ])

  # Map des routes avec lambda dédiée
  dedicated_lambda_routes_map = {
    for route in local.dedicated_lambda_routes :
    "${route.method}:${route.path}" => route.config
  }

  # Configuration des Lambdas dédiées
  lambda_configs = {
    for key, config in local.dedicated_lambda_routes_map :
    key => {
      memory_size = try(config.openapi_extra["x-conf"]["lambda"]["memory_size"], 128)
      timeout     = try(config.openapi_extra["x-conf"]["lambda"]["timeout"], 30)
      env_vars    = try(config.openapi_extra["x-env-variables-required"], [])
    }
  }
}
