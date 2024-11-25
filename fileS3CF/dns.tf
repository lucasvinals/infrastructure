resource "aws_route53_record" "file" {
  zone_id = var.dnsZoneId
  name    = local.route53Alias
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}