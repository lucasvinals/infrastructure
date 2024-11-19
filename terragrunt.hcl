generate "init" {
  path = "configure.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  cloud {
    organization = "lucasvinals_personal"

    workspaces {
      project = "TerraformCourse"
      tags = [ "${title(path_relative_to_include())}" ]
    }
  }
}

terraform {
  required_providers { aws = { source = "hashicorp/aws" } }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      CreatedBy       = "Lktz"
      Module          = "${title(path_relative_to_include())}"
    }
  }
}
EOF

}
