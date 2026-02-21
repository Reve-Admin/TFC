aws_region         = "us-east-1"
environment        = "dev"
vpc_id             = "vpc-0123456789abcdef0"
private_subnet_ids = ["subnet-0aaaa1111", "subnet-0bbbb2222", "subnet-0cccc3333"]
public_subnet_ids  = ["subnet-0dddd4444", "subnet-0eeee5555"]
tags = {
  Environment = "dev"
  Project     = "K8s-AI-Platform"
}