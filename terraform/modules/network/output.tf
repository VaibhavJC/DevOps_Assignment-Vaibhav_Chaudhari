output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.pub_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.pub_subnet_2.id
}

output "security_group_id" {
  value = aws_security_group.allow_ssh_http.id
}