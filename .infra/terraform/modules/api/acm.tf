# resource "aws_acm_certificate" "api" {
#   domain_name       = local.api-domain-name
#   validation_method = "DNS"

#   tags = merge(
#     var.default_tags,
#     {
#       Name = "${local.resource-prefix}-api-regional-certificate"
#     }
#   )
# }

# resource "aws_acm_certificate" "cognito" {
#   provider          = aws.acm_provider
#   domain_name       = local.cognito-domain-name
#   validation_method = "DNS"

#   tags = merge(
#     var.default_tags,
#     {
#       Name = "${local.resource-prefix}-cognito-certificate"
#     }
#   )
# }

