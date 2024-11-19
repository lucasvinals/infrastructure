output "instanceIp" {
  value = aws_instance.instance[*].private_ip
}