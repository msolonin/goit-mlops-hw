output "public_subnets" {
  description = "Public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "Private subnets"
  value       = aws_subnet.private[*].id
}

output "vpc_id" {
  description = "Id of VPC"
  value       = aws_vpc.main.id
}
