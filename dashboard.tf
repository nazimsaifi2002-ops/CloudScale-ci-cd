resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "cloud watch surveillance"
          region = var.region
          stat   = "Minimum"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_lb_target_group.web.arn_suffix, "LoadBalancer", aws_lb.web.arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "cpu utilization"
          region = var.region
          stat   = "Average"
          period = 300
          metrics = [
            [{ expression = "SEARCH('{AWS/EC2,InstanceId} CPUUtilization', 'Average', 300)", id = "cpu" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "network traffic"
          region = var.region
          stat   = "Sum"
          period = 300
          metrics = [
            [{ expression = "SEARCH('{AWS/EC2,InstanceId} NetworkIn', 'Sum',300)", id = "net" }]
          ]
        }
      }
    ]
  })
}

