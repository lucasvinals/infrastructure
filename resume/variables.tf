variable "resumeFileName" {
  default = "LucasVinalsCV.pdf"
}

#Route53
variable dnsNameServers {}
variable dnsZoneId {}
variable dnsHostedZoneName {}
variable acmCertificateValidationARN {}

locals {
  accountId = data.aws_caller_identity.current.account_id
  route53Alias = terraform.workspace == "production" ? var.dnsHostedZoneName : "${terraform.workspace}.${var.dnsHostedZoneName}" 
  bucketName = "resume-${local.route53Alias}"
}