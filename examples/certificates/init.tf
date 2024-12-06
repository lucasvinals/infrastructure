terraform {
  cloud {
    organization = "lucasvinals"

    workspaces {
      project = "Main"
      name    = "examplecertificates"
    }
  }
}

module "certificates" {
  source = "../../modules/certificates"

  dnsZoneId         = module.dns.route53.hostedZone.id
  dnsHostedZoneName = module.dns.route53.hostedZone.name
  dnsNameServers    = module.dns.route53.nameServers
}
