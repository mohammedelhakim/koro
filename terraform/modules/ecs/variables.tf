variable "cluster_name" {
    description = "Name of the ECS cluster"
    type        = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "security_group_id" {
    type = string
}

variable "nginx_php_image_url" {
    description = "ECR image URL for the container"
    type        = string
}

variable "aws_region" {
    type        = string
    description = "AWS Region"
}

variable "aws_vpc_id" {
    description = "ID of the AWS VPC"
}

variable "aws_lb_target_group_arn" {}
