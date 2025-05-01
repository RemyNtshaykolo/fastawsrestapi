

variable "domain_name" {
  type        = string
  description = "Domain name for the API Gateway without ending dot"
  default     = null
}

variable "image_tag" {
  type        = string
  description = "Image tag for the lambda function"
  default     = null
}



variable "stage" {
  type = string
}
variable "app_name" {
  type = string
}
variable "api_description" {
  description = "My API Gateway REST"
}

variable "alarm_threshold" {
  description = "how many error before activation"
  type        = number
  default     = 1
}

variable "alarm_period" {
  description = "scan window of alert is alarm_unit units"
  type        = number
  default     = 120
}

variable "lambda_env_variables" {
  description = "Environment variables for the lambda functions"
  type        = map(string)
  default     = {}
}

variable "doc_path" {
  description = "Path to the openapi documentation"
  type        = string
}

variable "lambda_handler" {
  type = string
}

variable "aws_iam_policy_document_list" {
  description = "Custom policy attached to iam role of lambda function"
  type        = any
  default     = []
}

variable "lambda_reviver" {
  description = "Lambda reviver to prevent cold start"
  type        = bool
  default     = false
}



variable "default_tags" {
  description = "Tags par défaut à appliquer à toutes les ressources"
  type        = map(string)
  default     = {}
}

variable "api_version" {
  type        = string
  description = "Version of the API (v1, v2, etc.)"
}

variable "ecr_repository_url" {
  description = "URL du repository ECR partagé"
  type        = string
}

variable "lambda_image_digest" {
  description = "Digest de l'image Lambda"
  type        = string
}

variable "lambda_image_id" {
  description = "ID de l'image Lambda"
  type        = string
}

variable "cognito_user_pool" {
  description = "Cognito user pool"
  type = object({
    id  = string
    arn = string
  })
}

variable "lambda_subnet_ids" {
  description = "Subnet IDs for the lambda function"
  type        = list(string)
  default     = []
}


variable "lambda_security_group_ids" {
  description = "Security group IDs for the lambda function"
  type        = list(string)
  default     = []
}

variable "use_custom_domain" {
  description = "Use custom domain for the API"
  type        = bool
  default     = false
}
