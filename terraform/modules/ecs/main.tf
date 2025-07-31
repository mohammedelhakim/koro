resource "aws_ecs_cluster" "this" {
    name = var.cluster_name
}

resource "aws_ecs_task_definition" "nginx_php" {
    family                   = "nginx-php"
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = "256"
    memory                   = "512"
    execution_role_arn       = aws_iam_role.execution_role.arn

    container_definitions = jsonencode([
        {
            name      = "nginx"
            image = "${var.image_url}"
            portMappings = [{
                containerPort = 80
                hostPort      = 80
            }]
            dependsOn = [{ containerName = "php", condition = "START" }]
        },
        {
            name  = "php"
            image = "php:8.2-fpm"
        }
    ])
}

resource "aws_iam_role" "execution_role" {
    name = "${var.cluster_name}-ecs-execution-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            },
            Effect = "Allow",
            Sid    = ""
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
    role       = aws_iam_role.execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "this" {
    name            = "${var.cluster_name}-service"
    cluster         = aws_ecs_cluster.this.id
    task_definition = aws_ecs_task_definition.nginx_php.arn
    desired_count   = 1
    launch_type     = "FARGATE"

    network_configuration {
        subnets         = var.subnet_ids
        assign_public_ip = true
        security_groups = [var.security_group_id]
    }

    depends_on = [aws_iam_role_policy_attachment.ecs_execution]
}
