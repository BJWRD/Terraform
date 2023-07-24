output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
  sensitive   = true
}

output "region" {
  description = "AWS region"
  value       = var.region
  sensitive   = true
}

# Output of the Kubernetes authentication - used for configuring the Kubernetes Provider
output "kubernetes_auth" {
  value = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
  sensitive = true
}

# Outputs the cluster ID for use in other modules and to output to the user
output "cluster_id" {
  description = "The cluster name of the EKS cluster"
  value       = module.eks.cluster_id
}