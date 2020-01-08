variable "app_name" {}
variable "env_name" {}
variable "globals" {
  type = "map"
}

variable "cluster-id" {
  description = "ID of the ECS cluster"
}

variable "target-group-factor-users" {
  description = "list of target groups for users"
}

variable "globals_tags" {
  type = "map"
}

variable "user-images" {
  type = "map"
}

variable "globals_subnet_ids" {
  type = "list"
}

variable "container_count" {
  description = "Number of docker containers to run"
  default     = 1
}


variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 1024
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 2048
}

variable "fargate_memory_reservation" {
  description = "Fargate instance memory reservation solft limit (in MiB)"
  default     = 2048
}

variable "container_name" {
  description = "Fargate container name"
  default     = ""
}

variable "ecs_execution_role_arn" {
  description = "ECS task execution role"
}

variable "task-security-group" {
  description = "Task security group"
}

variable "env_variables" {
  default = []
}

variable "cloudwatch_logs_dest_arn" {}


variable "container_port" {}

variable "host_port" {}