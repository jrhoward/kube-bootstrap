
locals {
  az_count =  length( data.aws_availability_zones.available.names )
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.cluster_name
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = "true"
  tags = merge(map(
    "Name", local.cluster_name,
    "kubernetes.io/cluster/${local.cluster_name}", "shared",
  ), local.tags)
}

resource "aws_subnet" "main" {
  count = local.az_count

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  vpc_id            = aws_vpc.main.id

  tags = merge(map(
    "Name", "${local.cluster_name}-${count.index}",
    "kubernetes.io/cluster/${local.cluster_name}", "shared",
  ), local.tags)
}


resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  count = local.az_count

  subnet_id      = aws_subnet.main.*.id[count.index]
  route_table_id = aws_route_table.main.id
}