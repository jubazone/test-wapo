resource "aws_ecr_repository" "privatebin" {
  name = "privatebin"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "default_policy" {
  repository = aws_ecr_repository.privatebin.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only the last ${var.untagged_images} untagged images.",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.untagged_images}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "null_resource" "docker_packaging" {

  provisioner "local-exec" {
    command = data.template_file.imagen.rendered
  }
  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_ecr_repository.privatebin,
  ]
}

data "template_file" "imagen" {
  template = file("${path.module}/install_docker.sh")
  vars = {
    aws_region     = var.aws_region,
    account_id     = var.account_id,
    repository_url = aws_ecr_repository.privatebin.repository_url
  }
}