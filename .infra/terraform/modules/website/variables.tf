variable "stage" {
  type        = string
  default     = ""
  description = "Stage of application"
}

variable "app_name" {
  type        = string
  description = "Name of static app"
}

variable "domain_name" {
  type        = string
  description = "Domain name of the website to be used"
}

variable "description" {
  type        = string
  description = "Description of the website"
}

variable "default_tags" {
  description = "Default tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "use_custom_domain" {
  type        = bool
  description = "Whether to use a custom domain name"
  default     = false
}




