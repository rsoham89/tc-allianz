resource "aws_iam_role" "node_groups" {
  name               = var.eks_node_policies.name
  assume_role_policy = file("${path.module}/policies/node_policy.json")
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = var.eks_node_policies.policy_arn.eks_node_policy
  role       = aws_iam_role.node_groups.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = var.eks_node_policies.policy_arn.eks_cni_policy
  role       = aws_iam_role.node_groups.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  policy_arn = var.eks_node_policies.policy_arn.eks_ecr_policy
  role       = aws_iam_role.node_groups.name
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node.node_group_name

  node_role_arn = aws_iam_role.node_groups.arn

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]

  scaling_config {
    desired_size = var.node.desired_size
    max_size     = var.node.max_size
    min_size     = var.node.min_size
  }

  ami_type             = var.node.ami_type
  capacity_type        = var.node.capacity_type
  disk_size            = var.node.disk_size
  force_update_version = var.node.force_update_version
  instance_types       = var.node.instance_types

  labels = {
    role = var.node.role
  }

  version = var.node.version

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
  ]
}
