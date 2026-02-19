# CloudWatch Dashboard for Elastic Beanstalk and RDS Monitoring
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "lumiatech-kpi-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # ==================== ELASTIC BEANSTALK SECTION ====================
      {
        type = "text"
        x    = 0
        y    = 0
        width = 24
        height = 1
        properties = {
          markdown = "# Elastic Beanstalk - env"
        }
      },
      
      # Environment Health
      {
        type = "metric"
        x    = 0
        y    = 1
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "EnvironmentHealth", { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Environment Health"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 4
            }
          }
          annotations = {
            horizontal = [
              {
                label = "Severe"
                value = 4
                fill  = "above"
                color = "#d13212"
              },
              {
                label = "Degraded"
                value = 3
                fill  = "between"
                color = "#ff9900"
              },
              {
                label = "Warning"
                value = 2
                fill  = "between"
                color = "#ffcc00"
              },
              {
                label = "Ok"
                value = 1
                fill  = "between"
                color = "#1f8c2c"
              }
            ]
          }
        }
      },

      # Application Requests
      {
        type = "metric"
        x    = 8
        y    = 1
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "ApplicationRequests2xx", { "stat" = "Sum", "label" = "2xx Success" }],
            [".", "ApplicationRequests4xx", { "stat" = "Sum", "label" = "4xx Client Error" }],
            [".", "ApplicationRequests5xx", { "stat" = "Sum", "label" = "5xx Server Error" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Application Requests by Status"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # Application Latency
      {
        type = "metric"
        x    = 16
        y    = 1
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "ApplicationLatencyP99", { "stat" = "Average", "label" = "P99" }],
            [".", "ApplicationLatencyP95", { "stat" = "Average", "label" = "P95" }],
            [".", "ApplicationLatencyP90", { "stat" = "Average", "label" = "P90" }],
            [".", "ApplicationLatencyP75", { "stat" = "Average", "label" = "P75" }],
            [".", "ApplicationLatencyP50", { "stat" = "Average", "label" = "P50" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Application Latency (seconds)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # Instance Health
      {
        type = "metric"
        x    = 0
        y    = 7
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "InstancesOk", { "stat" = "Average", "label" = "Healthy Instances" }],
            [".", "InstancesDegraded", { "stat" = "Average", "label" = "Degraded Instances" }],
            [".", "InstancesSevere", { "stat" = "Average", "label" = "Severe Instances" }]
          ]
          view    = "timeSeries"
          stacked = true
          region  = "us-east-1"
          title   = "Instance Health Status"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # EC2 CPU Utilization
      {
        type = "metric"
        x    = 8
        y    = 7
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "EC2 Instance CPU Utilization"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                label = "High CPU"
                value = 80
                fill  = "above"
                color = "#ff9900"
              }
            ]
          }
        }
      },

      # Network In/Out
      {
        type = "metric"
        x    = 16
        y    = 7
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", { "stat" = "Sum", "label" = "Network In" }],
            [".", "NetworkOut", { "stat" = "Sum", "label" = "Network Out" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Network Traffic (Bytes)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # Load Balancer Metrics
      {
        type = "metric"
        x    = 0
        y    = 13
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { "stat" = "Average" }],
            [".", "RequestCount", { "stat" = "Sum", "yAxis" = "right" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Load Balancer Performance"
          period  = 300
          yAxis = {
            left = {
              label = "Response Time (s)"
              min   = 0
            }
            right = {
              label = "Request Count"
              min   = 0
            }
          }
        }
      },

      # Healthy/Unhealthy Target Count
      {
        type = "metric"
        x    = 12
        y    = 13
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", { "stat" = "Average", "label" = "Healthy Targets" }],
            [".", "UnHealthyHostCount", { "stat" = "Average", "label" = "Unhealthy Targets" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Target Health"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # ==================== RDS SECTION ====================
      {
        type = "text"
        x    = 0
        y    = 19
        width = 24
        height = 1
        properties = {
          markdown = "# RDS Database Metrics"
        }
      },

      # RDS CPU Utilization
      {
        type = "metric"
        x    = 0
        y    = 20
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "RDS CPU Utilization"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                label = "High CPU"
                value = 80
                fill  = "above"
                color = "#ff9900"
              }
            ]
          }
        }
      },

      # RDS Database Connections
      {
        type = "metric"
        x    = 8
        y    = 20
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Database Connections"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # RDS Free Storage Space
      {
        type = "metric"
        x    = 16
        y    = 20
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Free Storage Space (Bytes)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # RDS Read/Write Latency
      {
        type = "metric"
        x    = 0
        y    = 26
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "ReadLatency", { "stat" = "Average", "label" = "Read Latency" }],
            [".", "WriteLatency", { "stat" = "Average", "label" = "Write Latency" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Database Read/Write Latency (seconds)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # RDS IOPS
      {
        type = "metric"
        x    = 12
        y    = 26
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "ReadIOPS", { "stat" = "Average", "label" = "Read IOPS" }],
            [".", "WriteIOPS", { "stat" = "Average", "label" = "Write IOPS" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Database IOPS"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # RDS Freeable Memory
      {
        type = "metric"
        x    = 0
        y    = 32
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeableMemory", { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Freeable Memory (Bytes)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },

      # RDS Swap Usage
      {
        type = "metric"
        x    = 8
        y    = 32
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "SwapUsage", { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Swap Usage (Bytes)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
          annotations = {
            horizontal = [
              {
                label = "Swap Usage Detected"
                value = 0
                fill  = "above"
                color = "#ff9900"
              }
            ]
          }
        }
      },

      # RDS Network Throughput
      {
        type = "metric"
        x    = 16
        y    = 32
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "NetworkReceiveThroughput", { "stat" = "Average", "label" = "Network In" }],
            [".", "NetworkTransmitThroughput", { "stat" = "Average", "label" = "Network Out" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Network Throughput (Bytes/sec)"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      }
    ]
  })
}


