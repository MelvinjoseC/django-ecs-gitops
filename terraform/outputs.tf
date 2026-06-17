output "alb_dns_name"         { value = aws_lb.main.dns_name }
output "ecr_repository_url"   { value = aws_ecr_repository.app.repository_url }
output "ecs_cluster_name"     { value = aws_ecs_cluster.main.name }
output "cloudwatch_log_group" { value = aws_cloudwatch_log_group.app.name }
output "ecs_tasks_security_group_id" { value = aws_security_group.ecs_tasks.id }

