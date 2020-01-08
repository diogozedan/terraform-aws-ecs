output "tg_factor_prod_arn" {
  value = aws_lb_target_group.factor-prod.id
}

output "tg_factor_users_arn" {
  value = aws_lb_target_group.factor-users
}

output "alb_security_group" {
  value = aws_security_group.alb-sg.id
}

output "aws_alb_dns_name" {
  value = aws_alb.alb.dns_name
}

output "aws_alb_zone_id" {
  value = aws_alb.alb.zone_id
}