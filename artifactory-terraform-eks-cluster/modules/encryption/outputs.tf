output "eks_key_arn" {
  description = "ARN of the KMS Key for encrypting EKS secrets"
  value       = aws_kms_key.eks.arn
}

output "ebs_key_arn" {
  description = "ARN of the KMS Key for encrypting EBS volumes"
  value       = aws_kms_key.ebs.arn
}