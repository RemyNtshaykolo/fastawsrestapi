# Lambda partagée pour toutes les routes standard
resource "aws_lambda_function" "shared" {
  image_uri        = "${var.ecr_repository_url}@${var.lambda_image_digest}"
  source_code_hash = split("sha256:", var.lambda_image_id)[1]
  description      = "Lambda partagée pour les routes standard - ${var.api_version}"
  package_type     = "Image"
  function_name    = "${local.lambda-prefix}-shared"
  timeout          = 30
  memory_size      = 1000

  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = var.lambda_security_group_ids
  }

  image_config {
    command = [var.lambda_handler]
  }

  environment {
    variables = var.lambda_env_variables
  }

  role = aws_iam_role.this.arn
}

# Lambdas dédiées pour les routes spécifiques
resource "aws_lambda_function" "dedicated" {
  for_each = local.lambda_configs

  image_uri        = "${var.ecr_repository_url}@${var.lambda_image_digest}"
  source_code_hash = split("sha256:", var.lambda_image_id)[1]
  description      = "Lambda dédiée pour la route ${each.key} - ${var.api_version}"
  package_type     = "Image"
  function_name    = "${local.lambda-prefix}-${replace(replace(each.key, ":", "-"), "/", "-")}"
  timeout          = each.value.timeout
  memory_size      = each.value.memory_size

  image_config {
    command = [var.lambda_handler]
  }

  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = var.lambda_security_group_ids
  }

  environment {
    variables = merge(
      var.lambda_env_variables,
      try(
        { for var in each.value.env_vars : var => var.lambda_env_variables[var] },
        {}
      )
    )
  }

  role = aws_iam_role.this.arn
}

# Permission pour que API Gateway appelle la Lambda partagée
resource "aws_lambda_permission" "shared" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shared.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# Permissions pour que API Gateway appelle les Lambdas dédiées
resource "aws_lambda_permission" "dedicated" {
  for_each = local.lambda_configs

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dedicated[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/${each.key}"
}

#================================================================================================
#  NOTE Policies Custom
#================================================================================================

resource "aws_iam_policy" "this_custom" {
  count = length(var.aws_iam_policy_document_list)

  name   = "${local.lambda-prefix}-custom-policy-${count.index}"
  policy = var.aws_iam_policy_document_list[count.index].json
}

resource "aws_iam_role_policy_attachment" "this_custom" {
  count = length(var.aws_iam_policy_document_list)

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this_custom[count.index].arn
}
