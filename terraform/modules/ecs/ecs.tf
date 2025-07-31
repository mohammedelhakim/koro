resource "aws_ecs_cluster" "this" {
    name = var.cluster_name
}

resource "aws_ecs_task_definition" "nginx_php" {
    family             = "nginx-php-task"
    network_mode       = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                = "256"
    memory             = "512"
    execution_role_arn = aws_iam_role.execution_role.arn
    task_role_arn      = aws_iam_role.execution_role.arn

    container_definitions = jsonencode([
        {
            name  = "nginx-php"
            image = var.nginx_php_image_url
            portMappings = [{ containerPort = 80 }]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group"         = "/ecs/koro"
                    "awslogs-region"        = var.aws_region
                    "awslogs-stream-prefix" = "nginx-php"
                }
            }
        },
    ])
}

resource "aws_ecs_service" "nginx_php" {
    name                   = "nginx-php-service"
    cluster                = aws_ecs_cluster.this.id
    task_definition        = aws_ecs_task_definition.nginx_php.arn
    launch_type            = "FARGATE"
    desired_count          = 1
    enable_execute_command = true
    network_configuration {
        subnets          = var.private_subnet_ids
        security_groups = [var.security_group_id]
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = var.aws_lb_target_group_arn
        container_name   = "nginx-php"
        container_port   = 80
    }
}

resource "aws_iam_role" "execution_role" {
    name = "${var.cluster_name}-ecs-execution-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole",
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                },
                Effect = "Allow",
                Sid    = ""
            }
        ]
    })
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
    name              = "/ecs/koro"
    retention_in_days = 1
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
    role       = aws_iam_role.execution_role.name
    policy_arn = aws_iam_policy.ecr_pull_all.arn
}

resource "aws_iam_policy" "ecr_pull_all" {
    name        = "ECRPullAllPolicy"
    description = "Allows ECS tasks to pull images from all ECR repositories"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "ecr:*",
                    "logs:*",
                    "ssmmessages:*"
                ],
                Resource = "*"
            },
            {
                "Effect" : "Allow",
                "Action" : [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource" : "${aws_cloudwatch_log_group.ecs_log_group.arn}:*"
            }
        ]
    })
}

resource "aws_security_group" "ecs_sg" {
    name   = "ecs-fargate-sg"
    vpc_id = var.aws_vpc_id
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        self      = true
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
