resource "aws_ecr_repository" "this" {
  force_delete = true
  name         = "${var.stage}-${var.app_name}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.stage}-${var.app_name}-ecr-repository"
    Stage   = var.stage
    Project = var.app_name
  }
}

data "aws_ecr_image" "lambda_image" {
  repository_name = aws_ecr_repository.this.name
  image_tag       = "lambda"
}

# Deleted intagged image older than 1 day
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 1 day",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
