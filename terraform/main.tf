provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
}

module "alb" {
    source                = "./modules/alb"
    aws_region            = var.aws_region
    aws_security_group_id = module.ecs.aws_security_group_id
    aws_vpc_id            = aws_vpc.main.id
}

module "ecs" {
    source                  = "./modules/ecs"
    cluster_name            = "Koro"
    private_subnet_ids      = module.alb.private_subnet_ids
    security_group_id       = module.ecs.aws_security_group_id
    nginx_php_image_url     = module.ecr["nginx_php"].repository_url
    aws_region              = var.aws_region
    aws_vpc_id              = aws_vpc.main.id
    aws_lb_target_group_arn = module.alb.aws_lb_target_group_arn
    depends_on = [
        module.ecr
    ]
}

module "ecr" {
    for_each        = local.docker_images
    source          = "./modules/ecr"
    repository_name = "koro-ecr-${each.value}"
    aws_region      = var.aws_region
    image_tag       = "test"
}
