output "vpc_id" {
  value       = aws_vpc.main.id
  description = "vpc id"
  sensitive   = false
}


output "cluster" {
  value       = aws_eks_cluster.eks.name
  description = "cluster name"
  sensitive   = false
}
