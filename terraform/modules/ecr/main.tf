resource "aws_ecr_repository" "this" {
    name = var.repository_name

    image_scanning_configuration {
        scan_on_push = true
    }

    image_tag_mutability = "MUTABLE"
}

/*
resource "null_resource" "build_and_push_images" {
    for_each = toset(var.images_to_build)

    provisioner "local-exec" {
        command = <<EOT
            aws ecr get-login-password --region ${var.aws_region} \
                | docker login --username AWS --password-stdin ${aws_ecr_repository.this.repository_url}

            docker build -f docker/nginx/Dockerfile . -t ${aws_ecr_repository.this.repository_url}/${each.value}:${var.image_tag}
            docker push $CI_REGISTRY_IMAGE/$CI_COMMIT_BRANCH/${each.value}:${var.image_tag}

            // docker build -f docker/nginx/Dockerfile . -t $CI_REGISTRY_IMAGE/$CI_COMMIT_BRANCH/nginx:$CI_COMMIT_SHORT_SHA
            // docker push $CI_REGISTRY_IMAGE/$CI_COMMIT_BRANCH/nginx:$CI_COMMIT_SHORT_SHA
            // docker build -f docker/php/Dockerfile . -t $CI_REGISTRY_IMAGE/$CI_COMMIT_BRANCH/php:$CI_COMMIT_SHORT_SHA
            // docker push $CI_REGISTRY_IMAGE/$CI_COMMIT_BRANCH/php:$CI_COMMIT_SHORT_SHA

    EOT
    }

    triggers = {
        image_build_time = timestamp()
    }
}*/
