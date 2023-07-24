#ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  tags = local.tags
}

#Task Definition for the Jenkins container
resource "aws_ecs_task_definition" "main" {
  family                   = var.ecs_task_family
  network_mode             = var.network_mode
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = [var.requires_compatibilities]
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.jenkins_image
      cpu       = var.container_cpu
      essential = var.essential
      memory    = var.container_memory
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_host_port
          protocol      = var.container_protocol
        }
      ]
      healthCheck = {
        command  = var.container_health_check_command
        interval = var.container_health_check_interval
        timeout  = var.container_health_check_timeout
        retries  = var.container_health_check_retries
      }
      environment = [
        {
          name  = var.container_environment_name
          value = var.container_environment_value
        },
        {
          name  = var.container_storage_name
          value = var.container_storage_value
        }
      ]
      mountPoints = [
        {
          sourceVolume  = var.container_mount_source_volume
          containerPath = var.container_mount_path
          readOnly      = var.container_mount_read_only
        }
      ]
      logConfiguration = {
        logDriver = var.container_log_driver
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = aws_cloudwatch_log_stream.main.name
        }
      }
    }
  ])

  volume {
    name = var.volume_name
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.main.id
      transit_encryption = var.transit_encryption
      root_directory     = var.efs_root_directory
      authorization_config {
        access_point_id = aws_efs_access_point.main.id
        iam             = var.efs_iam_authentication
      }
    }
  }

  tags = local.tags
}

#ECS Service
resource "aws_ecs_service" "main" {
  name            = var.ecs_service_name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = var.launch_type
  desired_count   = var.desired_count

  load_balancer {
    container_name   = var.container_name
    container_port   = var.container_port
    target_group_arn = aws_lb_target_group.main.arn
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs.id, aws_security_group.alb.id, aws_security_group.efs.id]
    subnets          = [var.subnet_ids[0]]
    assign_public_ip = var.ecs_assign_public_ip
  }

  tags = local.tags
}

#EFS File System
resource "aws_efs_file_system" "main" {
  creation_token = var.creation_token
  encrypted      = var.efs_encryption
  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = local.tags
}

#EFS File System Mount
resource "aws_efs_mount_target" "main" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[0]
  security_groups = [aws_security_group.efs.id]
}

#EFS File System Access Point - allows root access by Jenkins user
resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id
  posix_user {
    gid = var.efs_gid
    uid = var.efs_uid
  }
  root_directory {
    path = var.efs_path
    creation_info {
      owner_gid   = var.efs_owner_gid
      owner_uid   = var.efs_owner_uid 
      permissions = var.efs_permissions 
    }
  }
  tags = local.tags
}

#Cloudwatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = var.cloudwatch_log_group
  retention_in_days = var.cloudwatch_log_retention

  tags = local.tags
}

#Cloudwatch Log Stream 
resource "aws_cloudwatch_log_stream" "main" {
  name           = var.cloudwatch_log_stream
  log_group_name = aws_cloudwatch_log_group.main.name
}
