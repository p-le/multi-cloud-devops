provider "aws" {
  region = "ap-northeast-1"
  profile = "provisioner"
}

locals {
  env           = "dev"
  organization  = "phule-tf"
  cidr_block    = "172.16.0.0/16"
  numbit        = 8
}

resource "aws_vpc" "main" {
  cidr_block = local.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${local.organization}-${local.env}-vpc"
    Environemnt = local.env
  }
}

resource "aws_internet_gateway" "public_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.organization}-${local.env}-igw"
    Environemnt = local.env
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gw.id
  }

  tags = {
    Name = "${local.organization}-${local.env}-public-rt"
    Environemnt = local.env
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.organization}-${local.env}-private-rt"
    Environemnt = local.env
  }
}

module "subnets" {
  source            = "./modules/subnet"
  for_each          = toset(var.availability_zones)
  availability_zone = each.key
  env               = local.env
  name_prefix       = local.organization
  vpc_id            = aws_vpc.main.id

  subnet_cidrs      = [
    cidrsubnet(aws_vpc.main.cidr_block, local.numbit, index(var.availability_zones, each.key)*4 + 1),
    cidrsubnet(aws_vpc.main.cidr_block, local.numbit, index(var.availability_zones, each.key)*4 + 2)
  ]
}

resource "aws_route_table_association" "public" {
  for_each       = toset([for o in module.subnets: o.public])
  subnet_id      = each.key
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = toset([for o in module.subnets: o.private])
  subnet_id      = each.key
  route_table_id = aws_route_table.private.id
}



