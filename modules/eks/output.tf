output "identity" {
  value = aws_eks_cluster.sta_cluster.identity[0].oidc[0].issuer
}

output "cluster_details" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.sta_cluster.id
}

output "cluster_all" {
  value = aws_eks_cluster.sta_cluster
  
}

output "identity_all" {
  value = aws_eks_cluster.sta_cluster.identity
}