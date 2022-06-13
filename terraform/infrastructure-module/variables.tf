variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "backend" {
  type = map(any)
  default = {
    bucket = "tf-state-soham-poc-bucket"
    key    = "dev/eks/terraform.tfstate"
  }
}
variable "vpc" {
  type = map(any)
  default = {
    cidr_block                       = "192.168.0.0/16"
    instance_tenancy                 = "default"
    enable_dns_support               = true
    enable_dns_hostnames             = true
    enable_classiclink_dns_support   = false
    assign_generated_ipv6_cidr_block = false

  }
}

variable "public_subnets" {
  type = object({
    map_public_ip_on_launch = bool
    cluster                 = string
    elb                     = number
    owner                   = string
    public_1                = map(string)
    public_2                = map(string)

  })
  default = {
    map_public_ip_on_launch = true
    cluster                 = "shared"
    elb                     = 1
    owner                   = "Soham"
    public_1 = {
      name              = "public-1"
      cidr_block        = "192.168.0.0/18"
      availability_zone = "eu-central-1a"
    }
    public_2 = {
      name              = "public-2"
      cidr_block        = "192.168.64.0/18"
      availability_zone = "eu-central-1b"
    }
  }
}

variable "private_subnets" {
  type = object({
    cluster   = string
    elb       = number
    owner     = string
    private_1 = map(string)
    private_2 = map(string)

  })
  default = {
    cluster = "owned"
    elb     = 1
    owner   = "Soham"

    private_1 = {
      name              = "private-1"
      cidr_block        = "192.168.128.0/18"
      availability_zone = "eu-central-1a"
    }
    private_2 = {
      name              = "private-2"
      cidr_block        = "192.168.192.0/18"
      availability_zone = "eu-central-1b"
    }
  }
}

variable "az" {
  type = list(any)
  default = [
    "eu-central-1a",
    "eu-central-1b"
  ]
}

variable "nacl_ingress" {
  type = map(any)
  default = {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

variable "nacl_egress" {
  type = map(any)
  default = {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

variable "eks_cluster_policy" {
  type = map(any)
  default = {
    name       = "app-cluster-iam-role"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }
}

variable "eks_cluster" {
  type = map(any)
  default = {
    name                    = "app_cluster"
    version                 = "1.22"
    endpoint_private_access = false
    endpoint_public_access  = true
  }
}

variable "eks_node_policies" {
  type = object({
    name       = string
    policy_arn = map(string)
  })
  default = {
    name = "node-groups-iam-role"
    policy_arn = {
      eks_node_policy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      eks_cni_policy  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      eks_ecr_policy  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    }
  }
}

variable "node" {
  type = object({ node_group_name = string
    desired_size         = number
    max_size             = number
    min_size             = number
    ami_type             = string
    capacity_type        = string
    disk_size            = number
    force_update_version = bool
    instance_types       = list(string)
    role                 = string
    version              = string
  })
  default = {
    node_group_name      = "app_node"
    desired_size         = 1
    max_size             = 1
    min_size             = 1
    ami_type             = "AL2_x86_64"
    capacity_type        = "ON_DEMAND"
    disk_size            = 20
    force_update_version = false
    instance_types       = ["t2.large"]
    role                 = "app-node"
    version              = "1.22"
  }
}

variable "stage" {
  type    = string
  default = "any"
}

locals {
  stage = var.stage
  tags = {
    stage = local.stage
    owner = "Soham"
  }
}