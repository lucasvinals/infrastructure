locals {
  isProduction = terraform.workspace == "production"
  hostedZoneNamePrefix = local.isProduction ? "": "${terraform.workspace}."
  fullHostedZoneName = "${local.hostedZoneNamePrefix}${var.route53.hosted_zone_name}"
}

resource "aws_route53_delegation_set" "main" {
  reference_name = local.fullHostedZoneName
}

resource "aws_route53_zone" "primary" {
  name = local.fullHostedZoneName
  delegation_set_id = aws_route53_delegation_set.main.id
}