data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# KMS Key for Sandbox EBS (Still good practice to encrypt, even in sandbox)
resource "aws_kms_key" "ebs_key" {
  description             = "KMS key for encrypting Sandbox EC2 EBS volume"
  enable_key_rotation     = true
  deletion_window_in_days = 7 # Reduced window for sandbox cleanup
  tags                    = var.tags
}

resource "aws_kms_alias" "ebs_key_alias" {
  name          = "alias/${var.environment}-ec2-ebs-key"
  target_key_id = aws_kms_key.ebs_key.key_id
}

# Sandbox Security Group
resource "aws_security_group" "sandbox_ec2_sg" {
  name        = "${var.environment}-ec2-sg"
  description = "Security group for sandbox EC2 instance"
  vpc_id      = var.vpc_id

  # Optional: Allow SSH from within the VPC (e.g., from a VPN or Bastion)
  # Uncomment this block if you plan to use the key_name variable
  /*
  ingress {
    description = "Allow SSH from internal VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Replace with your VPC CIDR
  }
  */

  egress {
    description = "Allow all outbound traffic for sandbox testing"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = merge(var.tags, { Name = "${var.environment}-sg" })
}

# IAM Role for SSM (Allows terminal access right from the AWS Console)
resource "aws_iam_role" "ssm_role" {
  name = "${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ssm_role.name
}

# The Sandbox EC2 Instance
resource "aws_instance" "sandbox_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.sandbox_ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_name != "" ? var.key_name : null

  associate_public_ip_address = false 
  ebs_optimized               = true  
  monitoring                  = false # Disabled in sandbox to save CloudWatch costs

  # Keep IMDSv2 enabled - good habit for all environments
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" 
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_size           = 20 # Smaller disk for sandbox
    volume_type           = "gp3"
    encrypted             = true
    kms_key_id            = aws_kms_key.ebs_key.arn
    delete_on_termination = true
  }

  tags = merge(var.tags, { Name = "${var.environment}-server" })
}