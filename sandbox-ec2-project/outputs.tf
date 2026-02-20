output "instance_id" {
  description = "The ID of the hardened EC2 instance"
  value       = aws_instance.sandbox_server.id
}

output "instance_private_ip" {
  description = "The private IP address of the hardened EC2 instance"
  value       = aws_instance.sandbox_server.private_ip
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for EBS encryption"
  value       = aws_kms_key.ebs_key.arn

}
