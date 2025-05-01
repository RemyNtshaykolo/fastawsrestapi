variable "stage" {
  type        = string
  default     = ""
  description = "Stage of application"
}

variable "app_name" {
  type        = string
  description = "Name of static app"
}

variable "doc_domain_name" {
  type        = string
  description = "Domain name of the documentation website"
  default     = null
}


variable "default_tags" {
  description = "Tags par défaut à appliquer à toutes les ressources"
  type        = map(string)
  default     = {}
}



