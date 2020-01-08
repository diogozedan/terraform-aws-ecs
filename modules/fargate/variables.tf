variable "app_name" {}
variable "env_name" {}
variable "globals" {
  type = "map"
}

variable "globals_tags" {
  type = "map"
}



variable "alb_security_group" {
  description = "ALB security group"
}

variable "alb_factor_security_group" {
  description = "ALB security group"
}
