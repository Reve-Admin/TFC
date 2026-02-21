variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the database resources"
}

variable "db_sg_id" {
  type        = string
  description = "The ID of the security group assigned to the RDS database"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password for the PostgreSQL database"
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, staging, prod)"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to apply to all database resources"
}
variable "aws_region" {
  description = "AWS region for Pinecone serverless index"
  type        = string
}
