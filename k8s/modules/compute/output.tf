output "k8s_master_id" {
  description = "The EC2 instance ID of the Kubernetes Master node"
  value       = aws_instance.k8s_master.id
}

output "k8s_master_private_ip" {
  description = "The private IP address of the Kubernetes Master node"
  value       = aws_instance.k8s_master.private_ip
}

output "k8s_worker_ids" {
  description = "A list of EC2 instance IDs for the Kubernetes Worker nodes"
  value       = aws_instance.k8s_workers[*].id
}

output "k8s_worker_private_ips" {
  description = "A list of private IP addresses for the Kubernetes Worker nodes"
  value       = aws_instance.k8s_workers[*].private_ip
}

output "k8s_node_iam_role_arn" {
  description = "The ARN of the IAM role attached to the Kubernetes nodes"
  value       = aws_iam_role.k8s_node_role.arn
}

output "k8s_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for the cluster"
  value       = aws_cloudwatch_log_group.k8s_logs.name
}
