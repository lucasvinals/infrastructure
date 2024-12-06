#Route53
variable "dnsNameServers" {}
variable "dnsZoneId" {}
variable "dnsHostedZoneName" {}

variable "region" { default = "us-east-1" }

locals {
  environment  = terraform.workspace
  isProduction = local.environment == "production"
}
