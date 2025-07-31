output "ecs_cluster_id" {
    value = aws_ecs_cluster.this.id
}

output "ecs_cluster_arn" {
    value = aws_ecs_cluster.this.arn
}

output "aws_security_group_arn" {
    value = aws_security_group.ecs_sg.arn
}

output "aws_security_group_id" {
    value = aws_security_group.ecs_sg.id
}
