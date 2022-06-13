provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = var.backend.bucket
    key    = var.backend.key
    region = var.region
  }
}