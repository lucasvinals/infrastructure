locals {
  subdomain = terraform.workspace == "production" ? "testlb." : "testlb-${terraform.workspace}." 
}

resource "aws_route53_record" "root" {
  zone_id = var.dnsZoneId
  name = "${local.subdomain}${var.dnsHostedZoneName}"
  type = "A"

  alias {
    name = aws_lb.alb.dns_name
    zone_id = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}