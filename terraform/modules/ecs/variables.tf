variable "cluster_name" {
    description = "Name of the ECS cluster"
    type        = string
}

variable "subnet_ids" {
    type = list(string)
}

variable "security_group_id" {
    type = string
}

variable "image_url" {
    description = "ECR image URL for the container"
    type        = string
}
