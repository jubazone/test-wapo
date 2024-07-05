output "vpc_id" {
  value = aws_vpc.msk_vpc.id
}
output "ec2_webSG" {
  value = aws_security_group.ec2_webSG
}

output "ec2_dbSG" {
  value = aws_security_group.ec2_dbSG
}

output "private_subnet" {
  value = aws_subnet.private_subnet
}

output "public_subnet" {
  value = aws_subnet.public_subnet
}

