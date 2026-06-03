# 1. CloudWatch Log Group (store logs, auto-delete after 1 day to save costs)
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 1

  tags = {
    Name        = "/ecs/${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 2. IAM Execution Role & Policy
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-${var.environment}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_policy" "ecs_execution" {
  name        = "${var.project_name}-${var.environment}-execution-policy"
  description = "Policy for ECS task execution role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.db_secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_execution.arn
}

# 3. ECS Cluster, Task Definition, and Service
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}-cluster"

  # Disable container insights to avoid additional costs
  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Smallest/cheapest valid Fargate CPU/Memory combination
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # 0.25 vCPU (minimum)
  memory                   = 512 # 0.5 GB (minimum)
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.app_image
      essential = true
      environment = [
        {
          name  = "DB_LINK"
          value = "postgresql://postgres:${jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["password"]}@${jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["host"]}:5432/${jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["dbname"]}"
        }
      ]
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

data "aws_region" "current" {}

# Fetch the secret value to construct DB_LINK
data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = var.db_secret_arn
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.autoscaling.min_capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = var.app_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution,
    aws_cloudwatch_log_group.this
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ------------------------------------------------------------
# ECS Service Auto Scaling (placed outside the service resource)
# ------------------------------------------------------------

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.autoscaling.max_capacity
  min_capacity       = var.autoscaling.min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.project_name}-${var.environment}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling.cpu_target_value
    scale_in_cooldown  = var.autoscaling.scale_in_cooldown
    scale_out_cooldown = var.autoscaling.scale_out_cooldown
  }
}

# Optional service-linked role (if not already created automatically)
#resource "aws_iam_service_linked_role" "ecs_autoscaling" {
#  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
#  description      = "Role for ECS service auto scaling"
#}
