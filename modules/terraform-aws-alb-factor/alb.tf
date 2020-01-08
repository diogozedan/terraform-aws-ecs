resource "aws_security_group" "alb-sg" {
  name        = "${var.app_name}-alb-factor-sg"
  description = "control access to ALB for factor service"
  vpc_id      = var.globals["vpc_id"]

  tags = var.globals_tags

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 8100
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 8100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "alb" {
  name               = "ecs-${var.app_name}-factor-alb"
  internal           = true
  load_balancer_type = "application"
  idle_timeout       = "3600"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = var.globals_subnet_ids

  tags = var.globals_tags
}

resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_alb.alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.factor-prod.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "prod" {
  listener_arn = aws_lb_listener.listener1.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.factor-prod.arn
  }
  condition {
    field  = "path-pattern"
    values = ["/prod/*"]
  }
}

resource "aws_lb_listener_rule" "dynamic" {
  for_each = var.user-images
  listener_arn = aws_lb_listener.listener1.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.factor-users[each.key].arn
  }
  condition {
    field  = "path-pattern"
    values = ["/dynamic/*"]
  }
}

resource "null_resource" "update_rule_prod" {

  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
      AWS_ACCESS_KEY_ID=${var.access_key} \
      AWS_SECRET_ACCESS_KEY=${var.secret_key} \
      AWS_SESSION_TOKEN=${var.token} \
      AWS_DEFAULT_REGION=${var.region} \
      aws elbv2 modify-rule \
        --rule-arn=${aws_lb_listener_rule.prod.arn} \
        --conditions='
          [
            {
              "Field": "query-string",
              "QueryStringConfig": {
                "Values": [ 
                  {
                    "Key": "ws",
                    "Value": "prod"
                  } 
                ]
              }
            }
          ]
        '\
        --actions='[
          {
            "TargetGroupArn": "${aws_lb_target_group.factor-prod.arn}",
            "Type": "forward"
          }
        ]
        '
EOF
  }
}

resource "null_resource" "update_rule_dynamic" {
  for_each = var.user-images
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
      AWS_ACCESS_KEY_ID=${var.access_key} \
      AWS_SECRET_ACCESS_KEY=${var.secret_key} \
      AWS_SESSION_TOKEN=${var.token} \
      AWS_DEFAULT_REGION=${var.region} \
      aws elbv2 modify-rule \
        --rule-arn=${aws_lb_listener_rule.dynamic[each.key].arn} \
        --conditions='
          [
            {
              "Field": "query-string",
              "QueryStringConfig": {
                "Values": [ 
                  {
                    "Key": "ws",
                    "Value": "${each.key}"
                  } 
                ]
              }
            }
          ]
        '\
        --actions='[
          {
            "TargetGroupArn": "${aws_lb_target_group.factor-users[each.key].arn}",
            "Type": "forward"
          }
        ]
        '
EOF
  }
}

resource "aws_lb_target_group" "factor-prod" {
  name        = "${var.app_name}-factor-prod-tg"
  port        = 8100
  protocol    = "HTTP"
  vpc_id      = var.globals["vpc_id"]
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = var.globals_tags
}

resource "aws_lb_target_group" "factor-users" {
  for_each = var.user-images
  name        = "${var.app_name}-factor-${each.key}-tg"
  port        = 8100
  protocol    = "HTTP"
  vpc_id      = var.globals["vpc_id"]
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = var.globals_tags
}

