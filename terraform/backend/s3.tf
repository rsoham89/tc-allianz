resource "aws_s3_bucket" "state_storage" {
  bucket = var.state_storage.bucket
  acl    = var.state_storage.acl

  tags = {
    Name        = var.state_storage.Name
    Environment = var.state_storage.Environment
  }
}