provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "tf-state-allianz-soham-assignment-bucket"
    key    = "dev/eks/terraform.tfstate"
    region = "eu-central-1"
  }
}
