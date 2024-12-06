terraform {
  cloud {
    organization = "lucasvinals"

    workspaces {
      project = "Main"
      name    = "examplefiles"
    }
  }
}

module "resume" {
  source = "../../modules/publishFiles"

  dnsZoneId                   = module.dns.route53.hostedZone.id
  dnsHostedZoneName           = module.dns.route53.hostedZone.name
  dnsNameServers              = module.dns.route53.nameServers
  acmCertificateValidationARN = module.certs.acmCertificateValidationARN

  name        = "resume"
  fileName    = "resume.webp"
  contentType = "image/webp"
}
