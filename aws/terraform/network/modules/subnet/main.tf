locals {
  zone_idx = element(split("-", var.availability_zone), 2)
  public_cidr = element(var.subnet_cidrs, 0)
  private_cidr = element(var.subnet_cidrs, 1)
}

resource "aws_subnet" "public" {
  vpc_id            = var.vpc_id
  cidr_block        = local.public_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-${var.env}-pub-sn-${local.zone_idx}"
    Environment = var.env
    Type  = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = local.private_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-${var.env}-priv-sn-${local.zone_idx}"
    Environment = var.env
    Type  = "private"
  }
}
