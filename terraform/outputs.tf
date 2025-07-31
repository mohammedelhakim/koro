output "nginx_php_repository_url" {
    value = module.ecr["nginx_php"].repository_url
}

output "alb_dns_name" {
    value = module.alb.dns_name
}
