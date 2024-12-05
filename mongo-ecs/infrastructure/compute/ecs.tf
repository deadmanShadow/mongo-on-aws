data "aws_caller_identity" "current" {}




resource "aws_ecs_cluster" "app_cluster" {
  name = "app-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


# --------------------mongo task definition--------------------

resource "aws_cloudwatch_log_group" "mongo-logs" {
  name = "/mongo-logs"  

  retention_in_days = 30  
}

resource "aws_ecs_task_definition" "mongo_task_definition" {
  family                   = "mongo-task-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.task_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "mongo",
      image     = "public.ecr.aws/docker/library/mongo:8.0-rc",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 27017
          hostPort      = 27017
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "sharedvol"
          containerPath = "/data/db"
          readOnly      = false
        },
      ],
      environment = [
        {
          name  = "MONGO_INITDB_ROOT_USERNAME"
          value = "admin"
        },
        {
          name  = "MONGO_INITDB_DATABASE"
          value = "mongodb"
        },
      ],
      secrets = [
        {
          name      = "MONGO_INITDB_ROOT_PASSWORD"
          valueFrom = var.mongo_ssm_param_name
        }
      ],
      
      healthcheck = {
        command     = ["CMD-SHELL", "echo 'db.runCommand(\\\"ping\\\").ok' | mongosh mongodb://localhost:27017/test"]
        interval    = 30
        timeout     = 15
        retries     = 3
        startPeriod = 15
      },
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/mongo-logs"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "mongodb"
        }
      },
      
    }
  ])
  volume {
    name = "sharedvol"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.mongo_fs.id
      transit_encryption = "ENABLED"
      authorization_config {
        iam = "ENABLED"
      }
    }
  }
}


resource "aws_ecs_service" "mongo_service" {
  name            = "mongo-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.mongo_task_definition.id
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.mongo_sg_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mongo_discovery.arn
  }

}
