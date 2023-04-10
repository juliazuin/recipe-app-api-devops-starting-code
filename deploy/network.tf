resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  instance_tenancy = "default"

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-vpc" })
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-gw-main" })
  )
}
####################################################
# Public subnets - Inbound/Outbound internet acces #

# A Zone #
####################################################

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id

  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-public-a" })
  )
}


data "aws_route_table" "public_a" {
  subnet_id = var.subnet_id
  vpc_id    = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-public-a" })
  )
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = data.aws_route_table.public_a.id
}

resource "aws_route" "public_internet_access_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


resource "aws_eip" "public_a" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-public-a" })
  )
}

resource "aws_nat_gateway" "public_a" {
  allocation_id = aws_eip.public_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-public-a" })
  )
}

####################################################
# B Zone #
####################################################

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id

  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-public-b" })
  )
}


data "aws_route_table" "public_b" {
  subnet_id = var.subnet_id
  vpc_id    = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-public-b" })
  )
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = data.aws_route_table.public_b.id
}

resource "aws_route" "public_internet_access_b" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


resource "aws_eip" "public_b" {
  vpc = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-public-b" })
  )
}

resource "aws_nat_gateway" "public_b" {
  allocation_id = aws_eip.public_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = merge(
    local.common_tags,
    tomap({ "Name" : "${local.prefix}-public-b" })
  )
}