resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "django-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name  = "django-app"
    image = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"

    portMappings = [{
      containerPort = 8000
      protocol      = "tcp"
    }]

    environment = [
      { name = "DEBUG",         value = "False" },
      { name = "ALLOWED_HOSTS", value = var.allowed_hosts },
      { name = "DB_HOST",       value = var.db_host },
      { name = "DB_PORT",       value = "5432" },
      { name = "DB_NAME",       value = var.db_name },
    ]

    secrets = [
      { name = "DJANGO_SECRET_KEY", valueFrom = var.secret_key_arn },
      { name = "DB_USER",           valueFrom = var.db_user_arn },
      { name = "DB_PASSWORD",       valueFrom = var.db_password_arn },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.app.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }

    # We will update the healthCheck in a later commit to match our new python healthcheck
    healthCheck = {
      command     = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8000/api/', timeout=5)\" || exit 1"]
      interval    = 30
      timeout     = 10
      retries     = 3
      startPeriod = 30
    }
  }])
}

resource "aws_ecs_service" "app" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "django-app"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}
