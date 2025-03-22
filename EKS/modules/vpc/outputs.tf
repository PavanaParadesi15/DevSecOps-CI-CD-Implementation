output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# [*] operator is called the splat operator, which is used to get a list of all subnet IDs instead of just one.
# .id extracts the subnet IDs for each subnet in the list.
output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id         // retrieves the IDs of all private subnets. 
}

# Prints the list of all public subnet IDs
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}