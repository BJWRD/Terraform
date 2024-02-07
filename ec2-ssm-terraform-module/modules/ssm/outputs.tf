output "instance_profile" {
  description = "The IAM Instance Profile to be configured"
  value       = aws_iam_instance_profile.main.id
}