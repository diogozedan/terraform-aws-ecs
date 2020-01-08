module "alb-factor" {
  source = "../../modules/terraform-aws-alb-factor"
  user-images               = jsondecode(var.user-images)
  app_name                  = var.application
  globals                   = var.globals
  globals_tags              = var.globals_tags
  globals_subnet_ids        = var.subnet_ids
  access_key                = data.vault_aws_access_credentials.sts-creds.access_key
  secret_key                = data.vault_aws_access_credentials.sts-creds.secret_key
  token                     = data.vault_aws_access_credentials.sts-creds.security_token
  region                    = var.region
}

module "fargate" {
  source = "../../modules/fargate"
  app_name                  = var.application
  env_name                  = var.environment
  globals                   = var.globals
  globals_tags              = var.globals_tags
  alb_security_group        = module.alb.alb_security_group
  alb_factor_security_group = module.alb-factor.alb_security_group
}

module "ecs_service_dynamic_users" {
  source = "../../modules/terraform-aws-ecs-service-dyn"
  cluster-id                = module.fargate.cluster-id
  container_port            = 8100
  host_port                 = 8100
  container_count           = 1
  user-images               = jsondecode(var.user-images)
  app_name                  = var.application
  env_name                  = var.environment
  globals                   = var.globals
  globals_tags              = var.globals_tags
  globals_subnet_ids        = var.subnet_ids
  target-group-factor-users = module.alb-factor.tg_factor_users_arn
  task-security-group       = module.fargate.security-group
  ecs_execution_role_arn    = module.iam.ecs_execution_role_arn
  env_variables = [
    {
      "name"  = "AWS_REGION",
      "value" = var.region
    },
    {
      "name"  = "ENV_NAME",
      "value" = var.environment
    }
  ]
}