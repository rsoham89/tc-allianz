output "vpc_id" {
  value       = aws_vpc.main.id
  description = "vpc id"

  sensitive = false
}
