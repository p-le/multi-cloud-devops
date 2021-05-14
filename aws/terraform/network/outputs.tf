output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnets" {
  value = { for zone in var.availability_zones : zone => module.subnets[zone].public }
}
output "private_subnets" {
  value = { for zone in var.availability_zones : zone => module.subnets[zone].private }
}
