resource "aws_acm_certificate" "certificate" {
  count             = var.doc_domain_name != null ? 1 : 0
  provider          = aws.acm_provider
  domain_name       = var.doc_domain_name
  validation_method = "DNS"

  tags = merge(
    var.default_tags,
    {
      Name = "${var.stage}-${var.app_name}-website-certificate"
    }
  )
}
