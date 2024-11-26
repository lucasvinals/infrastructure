resource "aws_acm_certificate" "main" {
  domain_name               = var.dnsHostedZoneName
  subject_alternative_names = ["*.${var.dnsHostedZoneName}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

resource "aws_route53domains_registered_domain" "main" {
  count = terraform.workspace == "production" ? 1 : 0

  domain_name = var.dnsHostedZoneName

  dynamic "name_server" {
    for_each = var.dnsNameServers
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_record" "mainCertificateValidation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.dnsZoneId
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.mainCertificateValidation : record.fqdn]
}
