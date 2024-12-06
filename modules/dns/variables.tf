variable "route53" {
  description = "Route53 variables"

  type = object({
    hosted_zone_name = string
  })

  default = {
    hosted_zone_name = "lucasvinals.com"
  }
}

variable "region" { default = "us-east-1" }

locals {
  environment          = terraform.workspace
  isProduction         = local.environment == "production"
  hostedZoneNamePrefix = local.isProduction ? "" : "${local.environment}."
  fullHostedZoneName   = "${local.hostedZoneNamePrefix}${var.route53.hosted_zone_name}"
}
