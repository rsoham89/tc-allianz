variable "state_storage" {
  type = map(any)
  default = {

    bucket      = "tf-state-soham-poc-bucket"
    acl         = "private"
    Name        = "tfstate-storage"
    Environment = "dev"

  }
}



