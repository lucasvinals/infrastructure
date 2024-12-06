resource "aws_route53_delegation_set" "main" {
  reference_name = local.fullHostedZoneName
}

resource "aws_route53_zone" "primary" {
  name              = local.fullHostedZoneName
  delegation_set_id = aws_route53_delegation_set.main.id
}

data "aws_route53_zones" "all" {}

data "aws_route53_zone" "secondaryHostedZones" {
  for_each = toset(data.aws_route53_zones.all.ids)
  zone_id  = each.key
}

resource "aws_route53_record" "updatedNSRecordOnRootHostedZone" {
  # For each and filter all but production hosted zone
  for_each = {
    for zoneId, zone in data.aws_route53_zone.secondaryHostedZones : zoneId => zone
    if local.isProduction && zone.name != var.route53.hosted_zone_name
  }

  allow_overwrite = true
  zone_id         = aws_route53_zone.primary.id
  name            = each.value.name
  type            = "NS"
  ttl             = 21600
  records         = each.value.name_servers
}
