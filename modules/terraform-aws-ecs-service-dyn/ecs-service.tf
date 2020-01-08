data "template_file" "template" {
  template = "${file("../../modules/terraform-aws-ecs-service-dyn/taskdef.json")}"
  for_each = var.user-images
  vars = {
    DOCKER_IMAGE_NAME   = each.value
    CPU                 = var.fargate_cpu
    MEMORY              = var.fargate_memory
    CONTAINER_NAME      = "${var.app_name}-${var.env_name}-container-${each.key}"
    MEMORY_RESERVATION  = var.fargate_memory_reservation
    CONTAINER_PORT      = var.container_port
    HOST_PORT           = var.host_port
    ENVIRONMENT         = jsonencode(var.env_variables)
    TASK_DEFINITION_NAME= "${var.app_name}-${var.env_name}-taskdef-${each.key}"
  }
}

resource "aws_ecs_task_definition" "taskdef" {
  for_each                  = var.user-images
  family                    = "${var.app_name}-${var.env_name}-taskdef-${each.key}"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = var.fargate_cpu
  memory                    = var.fargate_memory
  container_definitions     = data.template_file.template[each.key].rendered
  execution_role_arn        = var.ecs_execution_role_arn
  task_role_arn             = var.ecs_execution_role_arn
}

resource "aws_ecs_service" "factor_svc_user" {
  for_each        = var.user-images
  name            = "${var.app_name}-${var.env_name}-service-${each.key}"
  cluster         = var.cluster-id
  desired_count   = var.container_count
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.taskdef[each.key].id

  network_configuration {
    security_groups = [var.task-security-group]
    subnets         = var.globals_subnet_ids
  }

  load_balancer {
    target_group_arn = var.target-group-factor-users[each.key].id
    container_name   = "${var.app_name}-${var.env_name}-container-${each.key}"
    container_port   = var.container_port
  }

}

# resource "aws_cloudwatch_log_subscription_filter" "task-subscription" {
#   for_each = "${var.user-images}"
#   name            = "cw_logs_sub_filter-${each.key}"
#   log_group_name  = "/aws/ecs/${aws_ecs_task_definition.taskdef[each.key].family}"
#   filter_pattern  = ""
#   destination_arn = "${var.cloudwatch_logs_dest_arn}"
#   distribution    = "ByLogStream"
# }