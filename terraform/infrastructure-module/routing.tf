resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = local.tags
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }

  tags = local.tags
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }

  tags = local.tags
}

# associations

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private2.id
}

resource "aws_network_acl" "main_nacl" {
  vpc_id = aws_vpc.main.id
  egress {
    protocol   = var.nacl_egress.protocol
    rule_no    = var.nacl_egress.rule_no
    action     = var.nacl_egress.action
    cidr_block = var.nacl_egress.cidr_block
    from_port  = var.nacl_egress.from_port
    to_port    = var.nacl_egress.to_port
  }

  ingress {
    protocol   = var.nacl_ingress.protocol
    rule_no    = var.nacl_ingress.rule_no
    action     = var.nacl_ingress.action
    cidr_block = var.nacl_ingress.cidr_block
    from_port  = var.nacl_ingress.from_port
    to_port    = var.nacl_ingress.to_port
  }
}
