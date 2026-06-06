resource "aws_eks_cluster" "sta_cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.role_arn
  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access = true
  }
}

resource "aws_eks_node_group" "worker-group" {
  count           = var.create_node_group ? var.number_of_nodegroups : 0
  cluster_name    = aws_eks_cluster.sta_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.node_group_subnet_id
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }
  ami_type       = var.ami_type
  capacity_type  = var.capacity_type
  instance_types = var.instance_types
  disk_size      = var.disk_size
}