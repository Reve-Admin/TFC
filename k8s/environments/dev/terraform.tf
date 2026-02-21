aws_region         = "ap-south-1"
environment        = "dev"
vpc_id             = "vpc-0622a59899133bf68"
private_subnet_ids = ["subnet-02a7049b4e44c2a8c", "subnet-01b3c7044809a3170"]
public_subnet_ids  = ["subnet-02b70761ff1a27bbe", "subnet-08c9a6964e50e0c9c"]
tags = {
  Environment = "dev"
  Project     = "K8s-AI-Platform"

}
