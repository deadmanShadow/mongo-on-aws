data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "appvpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "appvpc"
  }
}

resource "aws_internet_gateway" "app_gw" {
  vpc_id = resource.aws_vpc.appvpc.id

  tags = {
    Name = "app_gw"
  }

}



resource "aws_route_table" "app_rt_public" {
  vpc_id = resource.aws_vpc.appvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = resource.aws_internet_gateway.app_gw.id
  }

  tags = {
    Name = "app_rt_public"
  }
}

resource "aws_subnet" "app_public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.appvpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.appvpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "app_public_subnet"
  }
}

resource "aws_subnet" "app_private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.appvpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.appvpc.id
  tags = {
    Name = "app_private_subnet"
  }
}

resource "aws_route_table_association" "app_public_subnet_assoc" {
  count          = 2
  subnet_id      = element(aws_subnet.app_public.*.id, count.index)
  route_table_id = element(aws_route_table.app_rt_public.*.id, count.index)
}




resource "aws_eip" "app_gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.app_gw]
}

resource "aws_nat_gateway" "app_nat_gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.app_public.*.id, count.index)
  allocation_id = element(aws_eip.app_gateway.*.id, count.index)
}

resource "aws_route_table" "app_private" {
  count  = 2
  vpc_id = aws_vpc.appvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.app_nat_gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.app_private.*.id, count.index)
  route_table_id = element(aws_route_table.app_private.*.id, count.index)
}

resource "aws_security_group" "test_ec2_sg" {
  name        = "test-ec2-sg"
  description = "Security group for test"
  vpc_id      = aws_vpc.appvpc.id
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

resource "aws_security_group" "mongo_task_sg" {
  name        = "mongo-task-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.appvpc.id
  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.test_ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs_mongo_sg" {
  name        = "efs-mongo-sg"
  description = "sg for ECS"
  vpc_id      = aws_vpc.appvpc.id
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.appvpc.cidr_block]
  }
}


