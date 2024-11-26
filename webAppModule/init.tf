terraform {
  required_providers { aws = { source = "hashicorp/aws" } }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = title(terraform.workspace)
      CreatedBy   = "Lucas Viñals"
      Module      = "webApp"
    }
  }
}
