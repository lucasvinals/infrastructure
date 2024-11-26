locals {
  route53RecordName = "loadbalancedinstances.${var.dnsHostedZoneName}"
}

resource "aws_route53_record" "root" {
  zone_id = var.dnsZoneId
  name    = local.route53RecordName
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
