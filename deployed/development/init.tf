terraform {
  cloud {
    organization = "lucasvinals"

    workspaces {
      project = "Main"
      name    = "development"
    }
  }
}

module "resume" {
  source = "../../modules/publishFiles"

  dnsZoneId                   = module.dns.route53.hostedZone.id
  dnsHostedZoneName           = module.dns.route53.hostedZone.name
  dnsNameServers              = module.dns.route53.nameServers
  acmCertificateValidationARN = module.certificates.acmCertificateValidationARN

  name        = "resume"
  fileName    = "resume.webp"
  contentType = "image/webp"
}

module "intro" {
  source = "../../modules/publishFiles"

  dnsZoneId                   = module.dns.route53.hostedZone.id
  dnsHostedZoneName           = module.dns.route53.hostedZone.name
  dnsNameServers              = module.dns.route53.nameServers
  acmCertificateValidationARN = module.certificates.acmCertificateValidationARN

  name     = "intro"
  fileName = "introduction.mov"
}

module "dns" {
  source = "../../modules/dns"
}

module "certificates" {
  source = "../../modules/certificates"

  dnsZoneId         = module.dns.route53.hostedZone.id
  dnsHostedZoneName = module.dns.route53.hostedZone.name
  dnsNameServers    = module.dns.route53.nameServers
}

moved {
  from = module.certs
  to   = module.certificates
}
