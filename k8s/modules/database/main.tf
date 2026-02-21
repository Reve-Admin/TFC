# KMS Key
resource "aws_kms_key" "database_key" {
  description             = "KMS key for RDS and Secrets Manager"
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "database_key_alias" {
  name          = "alias/${var.environment}-database-key"
  target_key_id = aws_kms_key.database_key.key_id
}

# Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.environment}/rds/postgres"
  description = "PostgreSQL credentials"
  kms_key_id  = aws_kms_key.database_key.id
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = var.db_password
  })
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

# RDS PostgreSQL instance
resource "aws_db_instance" "postgres" {
  identifier                  = "${var.environment}-postgres"
  allocated_storage           = 200
  storage_type                = "gp3"
  engine                      = "postgres"
  engine_version              = "15.4" 
  instance_class              = "db.t4g.large"
  username                    = "dbadmin"
  password                    = var.db_password
  db_subnet_group_name        = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids      = [var.db_sg_id]
  kms_key_id                  = aws_kms_key.database_key.arn
  storage_encrypted           = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.environment}-postgres-final-snap"
  # SECURITY FIXES
  backup_retention_period         = 7
  multi_az                        = true
  deletion_protection             = true
  copy_tags_to_snapshot           = true
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = var.tags
}

# Pinecone Serverless Index
resource "pinecone_index" "vector_db" {
  name       = "${var.environment}-vector-db"
  dimension  = 1536
  metric     = "cosine"

  spec = {
    serverless = {
      cloud  = "aws"
      region = var.aws_region
    }
  }
}


