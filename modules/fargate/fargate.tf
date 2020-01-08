resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.env_name}-cluster"
}