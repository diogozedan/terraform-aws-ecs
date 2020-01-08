#Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks"
  description = "allow access from the ALB only"
  vpc_id      = var.globals["vpc_id"]

  tags = var.globals_tags

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 8100
    security_groups = [var.alb_security_group,var.alb_factor_security_group]
  }
  ingress {
    protocol        = "tcp"
    from_port       = 10101
    to_port         = 19090
    security_groups = [var.alb_security_group,var.alb_factor_security_group]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
