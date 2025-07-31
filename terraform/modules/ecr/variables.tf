variable "repository_name" {
    type        = string
    description = "Name of the ECR repository"
}

variable "aws_region" {
    type        = string
    description = "AWS Region"
}

variable "images_to_build" {
    default = [
        "nginx",
        "php"
    ]
}

variable "image_tag" {
    type        = string
    description = "Image tag"
}
