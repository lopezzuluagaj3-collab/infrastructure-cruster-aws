resource "aws_vpc" "vpc_principal" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.vpc_principal.id
  cidr_block              = var.cidr_publica
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-subnet-publica"
    }
  )
}

resource "aws_subnet" "subnet_privada" {
  vpc_id            = aws_vpc.vpc_principal.id
  cidr_block        = var.cidr_privada
  availability_zone = var.az

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-subnet-privada"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_principal.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_publica.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-gw"
    }
  )
}

resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.vpc_principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rt-publica"
    }
  )
}

resource "aws_route_table_association" "assoc_publica" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.rt_publica.id
}

resource "aws_route_table" "rt_privada" {
  vpc_id = aws_vpc.vpc_principal.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rt-privada"
    }
  )
}

resource "aws_route_table_association" "assoc_privada" {
  subnet_id      = aws_subnet.subnet_privada.id
  route_table_id = aws_route_table.rt_privada.id
}
