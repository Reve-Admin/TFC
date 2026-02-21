module "network" {
  source             = "./modules/network"
  vpc_id             = var.vpc_id
  public_subnet_ids  = var.public_subnet_ids
  environment        = var.environment
  tags               = var.tags
}

# Updated Module Call
module "database" {
  source             = "./modules/database"
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  db_sg_id           = module.network.rds_sg_id
  db_password        = var.db_password
  environment        = var.environment
  tags               = var.tags
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  k8s_sg_id          = module.network.k8s_sg_id
  alb_target_group_arn = module.network.alb_tg_arn
  environment        = var.environment
  tags               = var.tags
}