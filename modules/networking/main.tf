# ====================================================
# MÓDULO: networking
# Responsable de: VPC, Subnets, IGW, NAT, Route Tables
# ====================================================

resource "aws_vpc" "vpc_principal" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true

  tags = { Name = "VPC_curter" }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.vpc_principal.id
  cidr_block              = var.cidr_publica
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = { Name = "Subnet-Publica" }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id            = aws_vpc.vpc_principal.id
  cidr_block        = var.cidr_privada
  availability_zone = var.az

  tags = { Name = "Subnet-Privada" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_principal.id

  tags = { Name = "Internet-Gateway-Principal" }
}

resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_publica.id

  tags = { Name = "NAT-Gateway-Principal" }
}

resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.vpc_principal.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "Tabla-Enrutamiento-Publica" }
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
  tags = { Name = "Tabla-Enrutamiento-Privada" }
}

resource "aws_route_table_association" "assoc_privada" {
  subnet_id      = aws_subnet.subnet_privada.id
  route_table_id = aws_route_table.rt_privada.id
}
