resource "aws_iam_role" "eks_cluster" {
  name               = var.eks_cluster_policy.name
  assume_role_policy = file("${path.module}/policies/eks_cluster.json")
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = var.eks_cluster_policy.policy_arn
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks" {
  name = var.eks_cluster.name

  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_cluster.version

  vpc_config {
    endpoint_private_access = var.eks_cluster.endpoint_private_access
    endpoint_public_access  = var.eks_cluster.endpoint_public_access

    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}
