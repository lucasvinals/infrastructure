output "route53" {
  value = {
    nameServers = aws_route53_delegation_set.main.name_servers
    hostedZone = {
      name = aws_route53_zone.primary.name
      id   = aws_route53_zone.primary.zone_id
    }
    # This output is to create certificate validation (module.certs) after NS update in the root hosted zone
    NSRecordOnRootHostedZone = aws_route53_record.updatedNSRecordOnRootHostedZone
  }
}
