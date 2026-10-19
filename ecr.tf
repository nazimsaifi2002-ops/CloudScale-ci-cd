resource "aws_ecr_repository" "app" {
  name         = "cloudscale-app"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

