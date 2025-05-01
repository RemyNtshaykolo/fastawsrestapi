resource "random_string" "random_string" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "this" {
  bucket        = "${var.stage}.${var.app_name}.${random_string.random_string.result}"
  force_destroy = true

  tags = merge(
    var.default_tags,
    {
      Name = "${var.stage}-${var.app_name}-website-bucket"
    }
  )
}


data "aws_iam_policy_document" "s3_website_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
    ]
  }
}


resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_website_policy.json
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket             = aws_s3_bucket.this.id
  block_public_acls  = true
  ignore_public_acls = true
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
