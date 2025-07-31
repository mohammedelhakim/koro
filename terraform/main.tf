provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_a" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.public_a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
    subnet_id      = aws_subnet.public_b.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecs_sg" {
    name        = "ecs-fargate-sg"
    description = "Allow HTTP access"
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

module "ecs_cluster" {
    source            = "./modules/ecs"
    cluster_name      = "Koro"
    subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_group_id = aws_security_group.ecs_sg.id
    image_url         = module.ecr.repository_url
    depends_on = [
        module.ecr
    ]
}

module "ecr" {
    source          = "./modules/ecr"
    repository_name = "koro-ecr"
    aws_region      = var.aws_region
    image_tag       = "test"
}
