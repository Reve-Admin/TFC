output "k8s_sg_id" {
  description = "The ID of the security group for Kubernetes nodes"
  value       = aws_security_group.k8s_nodes.id
}

output "rds_sg_id" {
  description = "The ID of the security group for the RDS database"
  value       = aws_security_group.rds.id
}

output "alb_tg_arn" {
  description = "The ARN of the Target Group for the Application Load Balancer"
  value       = aws_lb_target_group.k8s_tg.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.k8s_alb.dns_name
}

output "alb_sg_id" {
  description = "The ID of the security group for the Application Load Balancer"
  value       = aws_security_group.alb.id
}
