resource "aws_route_table" "public" {
    vpc_id = var.aws_vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_subnet" "public_a" {
    vpc_id                  = var.aws_vpc_id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true
}

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.public_a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_a" {
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_a" {
    allocation_id = aws_eip.nat_a.id
    subnet_id     = aws_subnet.public_a.id
}

resource "aws_subnet" "public_b" {
    vpc_id                  = var.aws_vpc_id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = true
}

resource "aws_route_table_association" "b" {
    subnet_id      = aws_subnet.public_b.id
    route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_b" {
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_b" {
    allocation_id = aws_eip.nat_b.id
    subnet_id     = aws_subnet.public_b.id
}

resource "aws_lb" "koro" {
    name               = "koro-lb"
    internal           = false
    load_balancer_type = "application"
    subnets = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [var.aws_security_group_id]
}

resource "aws_lb_target_group" "koro" {
    name        = "koro-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = var.aws_vpc_id
    target_type = "ip"
    health_check {
        path                = "/healthcheck"
        matcher             = "200-399"
        interval            = 5
        timeout             = 2
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.koro.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.koro.arn
    }
}

resource "aws_subnet" "private_a" {
    vpc_id            = var.aws_vpc_id
    cidr_block        = "10.0.3.0/24"
    availability_zone = "eu-west-1a"
}

resource "aws_subnet" "private_b" {
    vpc_id            = var.aws_vpc_id
    cidr_block        = "10.0.4.0/24"
    availability_zone = "eu-west-1b"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = var.aws_vpc_id
}

resource "aws_route_table" "private_a" {
    vpc_id = var.aws_vpc_id
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_a.id
    }
}

resource "aws_route_table_association" "private_assoc_a" {
    subnet_id      = aws_subnet.private_a.id
    route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table" "private_b" {
    vpc_id = var.aws_vpc_id
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_b.id
    }
}

resource "aws_route_table_association" "private_assoc_b" {
    subnet_id      = aws_subnet.private_b.id
    route_table_id = aws_route_table.private_b.id
}
