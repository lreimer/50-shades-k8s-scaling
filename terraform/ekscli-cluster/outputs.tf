output "eks_cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster"
  value       = data.aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_auth_token" {
  description = "The IAM authentication token for the EKS cluster"
  value       = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

output "kubeconfig_content" {
  description = "The kubeconfig file content for the EKS cluster"
  value       = data.local_file.kubeconfig_output.content
}

output "kubeconfig_ca_data" {
  description = "The kubeconfig certificate authority data for the EKS cluster"
  value       = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
