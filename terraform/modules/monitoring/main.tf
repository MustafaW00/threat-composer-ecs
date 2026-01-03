# CloudWatch Dashboard - Creates a visual dashboard in AWS Console
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1: ECS Performance (CPU and Memory)
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.ecs_cluster_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS Performance"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      # Widget 2: ALB Health (Response times and request count)
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix],
            [".", "RequestCount", ".", ".", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Metrics"
        }
      },
      # Widget 3: Error Tracking (5XX errors from ALB)
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Application Errors"
        }
      },
      # Widget 4: Target Health (How many healthy containers)
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.target_group_arn_suffix, "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Healthy Targets"
        }
      }
    ]
  })
}

# Alarm 1: App is Down (no healthy containers)
resource "aws_cloudwatch_metric_alarm" "app_down" {
  alarm_name          = "${var.project_name}-app-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when no healthy targets are available"
  treat_missing_data  = "breaching"

  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }
}

# Alarm 2: High CPU Usage
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when CPU exceeds 80%"

  dimensions = {
    ServiceName = var.ecs_service_name
    ClusterName = var.ecs_cluster_name
  }
}

# Alarm 3: Too Many Errors
resource "aws_cloudwatch_metric_alarm" "high_errors" {
  alarm_name          = "${var.project_name}-high-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when 5XX errors exceed 10 in 5 minutes"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# Log Retention - Keep ECS logs for 7 days only (saves money)
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}
