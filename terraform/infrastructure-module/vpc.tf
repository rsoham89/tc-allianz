resource "aws_vpc" "main" {
  cidr_block       = var.vpc.cidr_block
  instance_tenancy = var.vpc.instance_tenancy

  enable_dns_support   = var.vpc.enable_dns_support
  enable_dns_hostnames = var.vpc.enable_dns_hostnames

  enable_classiclink_dns_support   = var.vpc.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.vpc.assign_generated_ipv6_cidr_block

  tags = local.tags
}

