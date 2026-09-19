resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.ecs_cluster_name}"
  retention_in_days = 30

  tags = {
    Name = "${var.ecs_cluster_name}-logs"
  }
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
  alarm_description   = "Triggered when ECS task CPU utilization exceeds 80% for 2 consecutive periods"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  tags = {
    Name = "${var.ecs_cluster_name}-cpu-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.ecs_cluster_name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Triggered when ECS task Memory utilization exceeds 85% for 2 consecutive periods"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  tags = {
    Name = "${var.ecs_cluster_name}-memory-alarm"
  }
}

resource "aws_sns_topic" "alerts" {
  name         = "${var.ecs_cluster_name}-alerts"
  display_name = "ECS Production Alerts"

  tags = {
    Name = "${var.ecs_cluster_name}-alerts"
  }
}
