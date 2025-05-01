output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "cloudfront_distribution_id" {
  value = var.doc_domain_name != null ? aws_cloudfront_distribution.this[0].id : null
}
