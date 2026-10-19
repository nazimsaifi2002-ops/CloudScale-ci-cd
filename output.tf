output "vpc_id" {
  description = "id of the vpc"
  value       = aws_vpc.main.id
}
output "public_subnet_ids" {
  description = "ids of public subnet "
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}
output "private_subnet_ids" {
  description = "ids of private subnet "
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
