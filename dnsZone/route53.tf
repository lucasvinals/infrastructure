locals {
  createDNSZone = terraform.workspace == "production"
}

data "aws_route53_zone" "primary" {
  count = local.createDNSZone ? 0 : 1
  name = var.route53.hosted_zone_name
}

resource "aws_route53_delegation_set" "main" {
  # reference_name = "Main"
}

resource "aws_route53_zone" "primary" {
  count = local.createDNSZone ? 1 : 0
  name = var.route53.hosted_zone_name
  delegation_set_id = aws_route53_delegation_set.main.id
}