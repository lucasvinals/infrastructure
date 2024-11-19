locals {
  dnsZone = terraform.workspace == "production" ? aws_route53_zone.primary[0] : data.aws_route53_zone.primary[0]
}

output "route53" {
  value = {
    nameServers = aws_route53_delegation_set.main.name_servers
    hostedZone = {
      name = local.dnsZone.name
      id = local.dnsZone.zone_id
    }
  }
}