output "private_subnets" {
  description = "The private subnets already created"
  value       = data.aws_subnet.private
}

output "public_subnets" {
  description = "The public subnets already created"
  value       = data.aws_subnet.public
}

output "external_nat_ip" {
  description = "IP Address of the NAT Gateway for the private subnets"
  value       = aws_nat_gateway.private.private_ip
}

