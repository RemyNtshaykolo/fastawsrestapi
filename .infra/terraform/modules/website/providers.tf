terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.89.0"
      configuration_aliases = [aws.acm_provider]
    }
  }
}
