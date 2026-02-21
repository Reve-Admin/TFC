# IAM Role and Profile remain the same...
resource "aws_iam_role" "k8s_node_role" {
  name = "${var.environment}-k8s-node-role"
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

resource "aws_iam_role_policy" "k8s_node_policy" {
  name = "${var.environment}-k8s-policy"
  role = aws_iam_role.k8s_node_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["ssm:GetParameter", "secretsmanager:GetSecretValue", "kms:Decrypt"]
        Resource = "*" # Consider restricting to specific KMS/Secret ARNs later
      }
    ]
  })
}

resource "aws_iam_instance_profile" "k8s_profile" {
  name = "${var.environment}-k8s-profile"
  role = aws_iam_role.k8s_node_role.name
}

data "aws_ami" "amazon_linux_arm64" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}

# Kubernetes Master Node
resource "aws_instance" "k8s_master" {
  ami                         = data.aws_ami.amazon_linux_arm64.id
  instance_type               = "m7g.large"
  subnet_id                   = var.private_subnet_ids[0]
  iam_instance_profile        = aws_iam_instance_profile.k8s_profile.name
  vpc_security_group_ids      = [var.k8s_sg_id]
  
  # SECURITY FIXES
  associate_public_ip_address = false
  ebs_optimized               = true
  monitoring                  = true

  metadata_options {
      http_endpoint = "enabled"
      http_tokens   = "required"
      http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = merge(var.tags, { Name = "${var.environment}-k8s-master", Role = "Master" })
}

# Kubernetes Worker Nodes
resource "aws_instance" "k8s_workers" {
  count                       = 3
  ami                         = data.aws_ami.amazon_linux_arm64.id
  instance_type               = "m7g.large"
  subnet_id                   = element(var.private_subnet_ids, count.index)
  iam_instance_profile        = aws_iam_instance_profile.k8s_profile.name
  vpc_security_group_ids      = [var.k8s_sg_id]

  # SECURITY FIXES
  associate_public_ip_address = false
  ebs_optimized               = true
  monitoring                  = true

  metadata_options {
    http_tokens = "required" # Enforce IMDSv2
  }

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = merge(var.tags, { Name = "${var.environment}-k8s-worker-${count.index + 1}", Role = "Worker" })
}

resource "aws_lb_target_group_attachment" "workers" {
  count            = 3
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.k8s_workers[count.index].id
  port             = 80 
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "k8s_logs" {
  name              = "/aws/k8s/${var.environment}-cluster"
  retention_in_days = 365 # Fixed Medium vulnerability (was 14)
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count               = 3
  alarm_name          = "${var.environment}-worker-${count.index}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm if CPU exceeds 80%"
  actions_enabled     = false # Set to true once an SNS topic ARN is provided
  dimensions = {
    InstanceId = aws_instance.k8s_workers[count.index].id
  }
  tags = var.tags

}
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "ec2_readonly" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
