resource "aws_cloudwatch_metric_alarm" "sqs-queue-alarm" {
  actions_enabled = true
  alarm_actions = [
    var.sns_topic_arn
  ]
  alarm_name          = "${var.pipeline}-empty-queue"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 1
  treat_missing_data  = "missing"

  dynamic "metric_query" {
    for_each = var.queues

    content {
      id          = "m${metric_query.key}"
      return_data = false

      metric {
        dimensions = {
          "QueueName" = metric_query.value
        }
        metric_name = "NumberOfMessagesDeleted"
        namespace   = "AWS/SQS"
        period      = 300
        stat        = "Maximum"
      }
    }
  }

  metric_query {
    expression  = "SUM(METRICS())"
    id          = "e1"
    label       = "EmptyQueue"
    return_data = true
  }
}