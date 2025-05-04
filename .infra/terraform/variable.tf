variable "stage" {
  type = string
}
variable "app_name" {
  type = string
}

variable "domain_name" {
  type        = string
  description = "Your domain name. You should have to its DNS records."
  default     = null
}


variable "api_versions" {
  description = "Versions for the API Gateway"
  type        = set(string)
}

variable "aws_account_id" {
  description = "AWS account IDs"
  type        = string

}

variable "aws_region" {
  description = "AWS region"
  type        = string
}


variable "usage_plans" {
  description = "Usage plan for the API Gateway"
  type = map(object({
    limit    = number
    offset   = number
    period   = string
    api_keys = optional(list(string))
  }))
  default = {
    basic = {
      limit    = 10000
      offset   = 0
      period   = "MONTH"
      api_keys = []
    }
  }
}

variable "oauth2_clients" {
  description = "OAuth2 clients allowed to access the API"
  type        = set(string)
}

variable "use_custom_domain" {
  description = "Use custom domain for the API"
  type        = bool
  default     = false
}

variable "use_custom_domain_for_documentation" {
  description = "Use custom domain for the documentation"
  type        = bool
  default     = false
}

variable "live_environment" {
  description = "Live environment"
  type        = bool
  default     = false
}
