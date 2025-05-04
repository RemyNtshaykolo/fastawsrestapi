output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "cloudfront_distribution_id" {
  value = var.use_custom_domain ? aws_cloudfront_distribution.this[0].id : null
}
