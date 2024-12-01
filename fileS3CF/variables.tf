#Route53
variable "dnsNameServers" {}
variable "dnsZoneId" {}
variable "dnsHostedZoneName" {}
variable "acmCertificateValidationARN" {}

# Global
variable "fileName" {}
variable "name" {}
variable "contentType" { default = "" }

locals {
  environment  = title(terraform.workspace)
  accountId    = data.aws_caller_identity.current.account_id
  route53Alias = "${var.name}.${var.dnsHostedZoneName}"
  contentType  = var.contentType != "" ? var.contentType : "application/${replace(basename(var.fileName), "/^.*\\./", "")}"
}