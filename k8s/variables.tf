variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of existing private subnet IDs"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of existing public subnet IDs for ALB"
}

variable "pinecone_api_key" {
  type        = string
  sensitive   = true
  description = "API key for Pinecone"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "PostgreSQL password"
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "K8s-Self-Hosted"
    ManagedBy   = "Terraform"
  }
}