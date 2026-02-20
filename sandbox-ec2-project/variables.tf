variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "sandbox"
}

variable "vpc_id" {
  type        = string
  description = "ID of the existing hardened VPC"
}

variable "private_subnet_id" {
  type        = string
  description = "ID of the existing subnet to deploy the EC2 instance in"
}

variable "instance_type" {
  type        = string
  default     = "t3.small" # Cost-effective for sandbox testing
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "(Optional) Name of an existing AWS Key Pair for SSH access if needed in the sandbox"
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "Sandbox-Testing"
    ManagedBy   = "Terraform"
    Environment = "sandbox"
    AutoStop    = "true" # Common sandbox tag for cost-saving Lambda scripts
  }

}
