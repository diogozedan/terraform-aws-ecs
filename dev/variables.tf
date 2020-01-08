variable "region" {
}

variable "environment" {
}

variable "application" {
}


variable "organization" {
}

#############################
# Security Config
#############################
variable "subnet_ids" {
  type = "list"
}

variable "user-images" {
}

variable "vpc_private_cidrs" {
  type = "list"
}

variable "vpc_id" {
}


variable "redshift_url" {
}

variable "redshift_user" {
}

#####################
# common 
#####################

variable "ecs_execution_policy" {
}

// Push Variables

variable "globals" {
  type = "map"
}

variable "globals_tags" {
  type = "map"
}

variable "zone_id" {}

variable "aliases" {
  type = "list"
}

variable "docker_image_dcc" {
  description = "ECR image for DCC"
}

variable "docker_image_factor" {
  description = "ECR image for factor service"
}
