resource "aws_cloudfront_distribution" "this" {
  count               = var.use_custom_domain ? 1 : 0
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.description
  default_root_object = "index.html"
  aliases             = ["${var.domain_name}"]
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "all"
      }
    }
  }
  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate[0].arn
    ssl_support_method  = "sni-only"
  }
  tags = merge(
    var.default_tags,
    {
      Name = "${var.stage}-${var.app_name}-website-distribution"
    }
  )
}
