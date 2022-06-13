resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets.public_1.cidr_block
  availability_zone       = var.public_subnets.public_1.availability_zone
  map_public_ip_on_launch = var.public_subnets.map_public_ip_on_launch

  tags = {
    Name                                = var.public_subnets.public_1.name
    "kubernetes.io/cluster/app_cluster" = var.public_subnets.cluster
    "kubernetes.io/role/elb"            = var.public_subnets.elb
    stage                               = local.stage
    owner                               = var.public_subnets.owner
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets.public_2.cidr_block
  availability_zone       = var.public_subnets.public_2.availability_zone
  map_public_ip_on_launch = var.public_subnets.map_public_ip_on_launch

  tags = {
    Name                                = var.public_subnets.public_2.name
    "kubernetes.io/cluster/app_cluster" = var.public_subnets.cluster
    "kubernetes.io/role/elb"            = var.public_subnets.elb
    stage                               = local.stage
    owner                               = var.public_subnets.owner
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets.private_1.cidr_block
  availability_zone = var.private_subnets.private_1.availability_zone

  tags = {
    Name                                = var.private_subnets.private_1.name
    "kubernetes.io/cluster/app_cluster" = var.private_subnets.cluster
    "kubernetes.io/role/elb"            = var.private_subnets.elb
    stage                               = local.stage
    owner                               = var.private_subnets.owner
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets.private_2.cidr_block
  availability_zone = var.private_subnets.private_2.availability_zone

  tags = {
    Name                                = var.private_subnets.private_2.name
    "kubernetes.io/cluster/app_cluster" = var.private_subnets.cluster
    "kubernetes.io/role/elb"            = var.private_subnets.elb
    stage                               = local.stage
    owner                               = var.private_subnets.owner
  }
}
