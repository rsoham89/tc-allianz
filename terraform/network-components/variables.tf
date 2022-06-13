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
