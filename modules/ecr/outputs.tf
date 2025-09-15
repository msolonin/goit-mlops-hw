output "repository_url" {
  description = "URL (hostname/імена) для docker push/pull."
  value       = aws_ecr_repository.ecr.repository_url
}
output "repository_arn" {
  description = "ARN створеного репозиторію."
  value       = aws_ecr_repository.ecr.arn
}