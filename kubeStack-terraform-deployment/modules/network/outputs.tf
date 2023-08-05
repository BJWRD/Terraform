output "vpc_id" {
  description = "The VPC to be deployed"
  value       = aws_vpc.main.id
}

output "private_subnets" {
  description = "The private subnets already created"
  value       = aws_subnet.private
}

output "public_subnets" {
  description = "The public subnets already created"
  value       = aws_subnet.public
}

output "external_nat_ip" {
  description = "IP Address of the NAT Gateway for the private subnets"
  value       = [for nat in aws_nat_gateway.private : nat.private_ip]
}