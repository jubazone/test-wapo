resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster_privatebin"
}

resource "aws_ecs_task_definition" "privatebin_task" {
  family                   = "privatebin-tsk"
  container_definitions    = jsonencode([
    {
      name: "privatebin-tsk",
      image: "471112894115.dkr.ecr.us-east-1.amazonaws.com/privatebin:latest",
      essential: true,
      portMappings: [
        {
          containerPort: 8080,
          hostPort: 8080
        }
      ],
      memory: 512,
      cpu: 256
    }
  ])
 
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 512         # Specify the memory the container requires you can specify yours
  cpu                      = 256         # Specify the CPU the container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  depends_on = [
    null_resource.docker_packaging,
  ]
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_alb" "application_load_balancer" {
  name               = "lb-privatebin"
  load_balancer_type = "application"
  security_groups    = [var.ecs_SG.id]
  subnets            = [var.subnet[0].id, var.subnet[1].id]
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "private_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.privatebin_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.privatebin_task.family
    container_port   = 8080
  }

  network_configuration {
    subnets          = [var.subnet[0].id]
    assign_public_ip = true
    security_groups  = [var.ecs_SG.id]
  }
}