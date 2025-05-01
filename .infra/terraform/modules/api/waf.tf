# resource "aws_wafv2_web_acl" "this" {
#   name  = "${var.stage}-${var.app_name}-waf"
#   scope = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = false
#     metric_name                = "friendly-metric-name"
#     sampled_requests_enabled   = false
#   }

#   tags = merge(
#     var.default_tags,
#     {
#       Name = "${var.stage}-${var.app_name}-waf"
#     }
#   )
# }

# resource "aws_wafv2_web_acl_association" "this" {
#   resource_arn = aws_api_gateway_stage.this.arn
#   web_acl_arn  = aws_wafv2_web_acl.this.arn
# }
