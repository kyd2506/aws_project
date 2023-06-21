resource "aws_vpc" "aws14-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

tags = {
  Name = "aws14-vpc"
  }
}

resource "aws_subnet" "aws14_public_subnet2a" {
	vpc_id = aws_vpc.aws14-vpc.id
	cidr_block = var.public_subnet[0]
	availability_zone = var.azs[0]

	tags = {
		Name = "aws14-public-subnet2c"
	}
}

resource "aws_subnet" "aws14_public_subnet2c" {
	vpc_id = aws_vpc.aws14-vpc.id
	cidr_block = var.public_subnet[1]
	availability_zone = var.azs[1]

	tags = {
		Name = "aws14-public-subnet2c"
	}
}

resource "aws_subnet" "aws14_private_subnet2a" {
	vpc_id = aws_vpc.aws14-vpc.id
	cidr_block = var.private_subnet[0]
	availability_zone = var.azs[0]

	tags = {
		Name = "aws14-private-subnet2a"
	}
}

resource "aws_subnet" "aws14_private_subnet2c" {
	vpc_id = aws_vpc.aws14-vpc.id
	cidr_block = var.private_subnet[1]
	availability_zone = var.azs[1]

	tags = {
		Name = "aws14-private-subnet2c"
	}
}

#Internet Gateway
resource "aws_internet_gateway" "aws14_igw" {
	vpc_id = aws_vpc.aws14-vpc.id

	tags = {
		Name = "aws14-Internet-gateway"
	}
}

#EIP for NAT Gateway
resource "aws_eip" "aws14_eip" {
	vpc = true
	depends_on = [ "aws_internet_gateway.aws14_igw" ]
	lifecycle {
		create_before_destroy = true
	}
}

#NAT Gateway
resource "aws_nat_gateway" "aws14_nat" {
	allocation_id = aws_eip.aws14_eip.id
	subnet_id = aws_subnet.aws14_public_subnet2a.id
	depends_on = ["aws_internet_gateway.aws14_igw"]
}

#AWS에서 VPC를 생성하면 자동으로 route table이 하나 생긴다.
#aws_default_route_table은 route table을 만들지 않고 VPC가 만든
#기본 route table을 가져와서 terraform이 관리 할 수 있게 한다. 
resource "aws_default_route_table" "aws14_public_rt" {
  default_route_table_id = aws_vpc.aws14-vpc.default_route_table_id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.aws14_igw.id

	}
  tags = {
    Name = "aws14 public route table"
    }
}

resource "aws_route_table_association" "aws14_public_rta_2a" {
	subnet_id = aws_subnet.aws14_public_subnet2a.id
	route_table_id = aws_default_route_table.aws14_public_rt.id
}

resource "aws_route_table_association" "aws14_public_rta_2c" {
	subnet_id = aws_subnet.aws14_public_subnet2c.id
	route_table_id = aws_default_route_table.aws14_public_rt.id
}

resource "aws_route_table" "aws14_private_rt" {
	vpc_id = aws_vpc.aws14-vpc.id
	tags = {
	  Name = "aws14 private route table"
	}
}

resource "aws_route_table_association" "aws14_private_rta_2a" {
	subnet_id = aws_subnet.aws14_private_subnet2a.id
	route_table_id = aws_route_table.aws14_private_rt.id
}

resource "aws_route_table_association" "aws14_private_rta_2c" {
	subnet_id = aws_subnet.aws14_private_subnet2c.id
	route_table_id = aws_route_table.aws14_private_rt.id
}

resource "aws_route" "aws14_private_rt_table" {
	route_table_id = aws_route_table.aws14_private_rt.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.aws14_nat.id
}