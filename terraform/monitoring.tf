resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.ecs_cluster_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.ecs_cluster_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
}

resource "aws_sns_topic" "alerts" {
  name = "${var.ecs_cluster_name}-alerts"
}
