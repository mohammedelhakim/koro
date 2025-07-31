output "aws_lb_target_group_arn" {
    value = aws_lb_target_group.koro.arn
}

output "private_subnet_ids" {
    value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "dns_name" {
    value = aws_lb.koro.dns_name
}
