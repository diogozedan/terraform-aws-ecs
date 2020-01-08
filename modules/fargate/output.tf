output "cluster-id" {
    value = aws_ecs_cluster.main.id
}

output "security-group" {
    value = aws_security_group.ecs_tasks.id
}

