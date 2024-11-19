variable "route53" {
  description = "Route53 variables"

  type = object({
    hosted_zone_name = string
  })

  default = {
    hosted_zone_name = "lucasvinals.com"
  }
}