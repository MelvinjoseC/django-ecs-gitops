resource "aws_security_group" "alb" {
  name        = "${var.ecs_cluster_name}-alb-sg"
  description = "Controls HTTP traffic to the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound HTTP traffic from ALB to any target"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ecs_cluster_name}-alb-sg"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.ecs_cluster_name}-ecs-sg"
  description = "Allows inbound traffic only from the ALB and outbound internet access for dependencies"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound traffic from ALB only"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic to internet for pulling images and fetching parameters"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ecs_cluster_name}-ecs-sg"
  }
}
