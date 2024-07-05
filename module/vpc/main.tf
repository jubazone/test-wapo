resource "aws_vpc" "msk_vpc" {
  cidr_block = var.vpc_cidr
}


data "aws_availability_zones" "available" {}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.msk_vpc.id
  cidr_block        = element(split(",", join(",", var.private_subnet_cidrs)), count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  enable_resource_name_dns_a_record_on_launch = true
  private_dns_hostname_type_on_launch         = "resource-name"

}


resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.msk_vpc.id
  cidr_block        = element(split(",", join(",", var.public_subnet_cidrs)), count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true
  private_dns_hostname_type_on_launch         = "resource-name"
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.msk_vpc.id
}

resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "main-natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
}

resource "aws_route_table" "vpc_private_rt" {
  vpc_id = aws_vpc.msk_vpc.id
}

resource "aws_route_table" "vpc_public_rt" {
  vpc_id = aws_vpc.msk_vpc.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.vpc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.vpc_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main-natgw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.vpc_public_rt.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.vpc_private_rt.id
}

resource "aws_security_group" "ec2_dbSG" {
  name        = "msk-${lower(var.environment)}-sg-dbSG"
  vpc_id      = aws_vpc.msk_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "ec2_webSG" {
  name        = "msk-${lower(var.environment)}-sg-webSG"
  vpc_id      = aws_vpc.msk_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}