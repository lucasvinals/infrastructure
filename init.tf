module "dns" {
  source = "./dnsZone"
}

module "certs" {
  source = "./certificates"

  dnsZoneId = module.dns.route53.hostedZone.id
  dnsHostedZoneName = module.dns.route53.hostedZone.name
  dnsNameServers = module.dns.route53.nameServers
}

# module "webApp" {
#   source = "./webAppModule"

#   dnsZoneId = module.dns.route53.hostedZone.id
#   dnsHostedZoneName = module.dns.route53.hostedZone.name
# }

module "resume" {
  source = "./resume"

  dnsZoneId = module.dns.route53.hostedZone.id
  dnsHostedZoneName = module.dns.route53.hostedZone.name
  dnsNameServers = module.dns.route53.nameServers
  acmCertificateValidationARN = module.certs.acmCertificateValidationARN
}