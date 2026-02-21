# modules/network/variables.tf

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate for the HTTPS listener"
}
