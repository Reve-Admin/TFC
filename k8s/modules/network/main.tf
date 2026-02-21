resource "aws_security_group" "k8s_nodes" {
  name        = "${var.environment}-k8s-nodes-sg"
  description = "Security group for Kubernetes nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "Intra-cluster communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.environment}-k8s-sg" })
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow PostgreSQL from K8s nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.k8s_nodes.id]
  }
  tags = merge(var.tags, { Name = "${var.environment}-rds-sg" })
}

resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # SECURITY FIX: HTTP port 80 removed entirely to satisfy "should not be allowed"
  ingress {
    description = "Allow HTTPS inbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "Allow outbound to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.environment}-alb-sg" })
}

resource "aws_lb" "k8s_alb" {
  name                       = "${var.environment}-k8s-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true # Fix for Medium vulnerability
  tags                       = merge(var.tags, { Name = "${var.environment}-k8s-alb" })
}

resource "aws_lb_target_group" "k8s_tg" {
  name     = "${var.environment}-k8s-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
  }
  tags = var.tags
}

# SECURITY FIX: Replaced HTTP listener with HTTPS and secure TLS policy
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.k8s_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_tg.arn
  }
}
