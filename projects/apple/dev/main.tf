module "network" {
  source = "./modules/network"

  vpc_cidr             = var.vpc_cidr
  project_name         = var.project_name
  environment          = var.environment
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  rds_subnet_cidrs     = var.rds_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "database" {
  source        = "./modules/database"
  db_subnet_ids = module.network.rds_subnet_ids # from your network module
  db_sg_id      = module.network.rds_sg_id      # RDS security group ID
  project_name  = var.project_name              # from root variables.tf
  environment   = var.environment               # from root variables.tf
}

module "ecr" {
  source = "./modules/aws_services/ecr"
}

module "loadbalancers" {
  source            = "./modules/aws_services/loadbalancers"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.network.alb_sg_id # from your security_groups.tf
  app_port          = 8000
  certificate_arn   = "arn:aws:acm:ap-south-1:963462797840:certificate/314ab6ea-495f-4d5b-b405-f7f81a36a007"
}

module "dns" {
  source           = "./modules/aws_services/dns"
  alb_dns_name     = module.loadbalancers.alb_dns_name
  alb_zone_id      = module.loadbalancers.alb_zone_id
  alb_arn          = module.loadbalancers.alb_arn
  target_group_arn = module.loadbalancers.target_group_arn
}

module "clusters" {
  source             = "./modules/clusters"
  private_subnet_ids = module.network.private_subnet_ids
  ecs_sg_id          = module.network.ecs_sg_id
  db_secret_arn      = module.database.db_secret_arn
  app_image          = var.app_image
  app_port           = 8000
  target_group_arn   = module.loadbalancers.target_group_arn
}
