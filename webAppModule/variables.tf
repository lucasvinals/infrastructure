# EC2
variable "ec2Instances" {
  description = "EC2 instances values"

  type = object({
    instance_type = string,
    ami           = string
    count         = number
  })

  nullable = false

  default = {
    instance_type = "t2.micro",
    ami           = "ami-0cad6ee50670e3d0e"
    count         = 2
  }
}

#Route53
variable "dnsZoneId" {}
variable "dnsHostedZoneName" {}
