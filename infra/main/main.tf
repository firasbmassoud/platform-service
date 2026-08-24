data "aws_ecr_repository" "app" {
  name = var.project_name
}

module "network" {
  source = "../modules/network"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  az_count     = var.az_count
}

module "alb" {
  source = "../modules/alb"

  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  container_port    = var.container_port
  health_check_path = "/health"
}

module "service" {
  source = "../modules/ecs-service"

  project_name          = var.project_name
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  image                 = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
  container_port        = var.container_port
  desired_count         = var.desired_count
  cpu                   = var.task_cpu
  memory                = var.task_memory

  depends_on = [module.alb]
}
