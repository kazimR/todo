output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_security_group" {
  value = "${aws_security_group.default.id}"
}



output "public_subnet_ids" {
  value       = aws_subnet.public_subnet.*.id
  description = "The ID of the subnet."
}
output "public_subnet_cidrs" {
  value       = aws_subnet.public_subnet.*.cidr_block
  description = "CIDR blocks of the created public subnets."
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnet.*.id
  description = "The ID of the private subnet."
}

output "private_subnet_cidrs" {
  value       = aws_subnet.private_subnet.*.cidr_block
  description = "CIDR blocks of the created private subnets."
}
