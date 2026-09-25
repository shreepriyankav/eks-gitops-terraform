output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "CA certificate of the EKS cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_name" {
  description = "Name of the EKS managed node group"
  value       = aws_eks_node_group.this.node_group_name
}

output "cluster_security_group_id" {
  description = "Security group ID created for the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}