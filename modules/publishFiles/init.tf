terraform {
  required_providers { aws = { source = "hashicorp/aws" } }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = local.environment
      CreatedBy   = "Lucas Viñals"
      Module      = upper(element(split("/", path.module), length(split("/", path.module)) - 1))
    }
  }
}
