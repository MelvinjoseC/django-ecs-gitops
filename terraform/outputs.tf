output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "The URL of the Amazon ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "The name of the provisioned ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "The name of the provisioned ECS service"
  value       = aws_ecs_service.app.name
}

output "cloudwatch_log_group" {
  description = "The name of the CloudWatch Log Group for ECS application logs"
  value       = aws_cloudwatch_log_group.app.name
}

output "ecs_tasks_security_group_id" {
  description = "The Security Group ID assigned to ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}
