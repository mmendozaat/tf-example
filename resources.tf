# aws_sqs_queue.queue1:
resource "aws_sqs_queue" "queue1" {
  content_based_deduplication = false
  delay_seconds               = 60
  fifo_queue                  = true
  message_retention_seconds   = 43200
  name                        = "q1.fifo"
  receive_wait_time_seconds   = 20
  visibility_timeout_seconds  = 900
}

# aws_sqs_queue.queue2:
resource "aws_sqs_queue" "queue2" {
  content_based_deduplication = false
  delay_seconds               = 60
  fifo_queue                  = true
  message_retention_seconds   = 43200
  name                        = "q2.fifo"
  receive_wait_time_seconds   = 20
  tags                        = {}
  visibility_timeout_seconds  = 900
}

# aws_sqs_queue.queue1:
resource "aws_sqs_queue" "queue-a1" {
  content_based_deduplication = false
  delay_seconds               = 60
  fifo_queue                  = true
  message_retention_seconds   = 43200
  name                        = "a1.fifo"
  receive_wait_time_seconds   = 20
  visibility_timeout_seconds  = 900
}

# aws_sqs_queue.queue2:
resource "aws_sqs_queue" "queue-a2" {
  content_based_deduplication = false
  delay_seconds               = 60
  fifo_queue                  = true
  message_retention_seconds   = 43200
  name                        = "a2.fifo"
  receive_wait_time_seconds   = 20
  tags                        = {}
  visibility_timeout_seconds  = 900
}

# aws_sqs_queue.queue1:
resource "aws_sqs_queue" "queue-b1" {
  content_based_deduplication = false
  delay_seconds               = 60
  fifo_queue                  = true
  message_retention_seconds   = 43200
  name                        = "b1.fifo"
  receive_wait_time_seconds   = 20
  visibility_timeout_seconds  = 900
}

# aws_sqs_queue.queue2:
resource "aws_sqs_queue" "queue-b2" {
  content_based_deduplication = false
  delay_seconds               = 60
  fifo_queue                  = true
  message_retention_seconds   = 43200
  name                        = "b2.fifo"
  receive_wait_time_seconds   = 20
  tags                        = {}
  visibility_timeout_seconds  = 900
}

resource "aws_sns_topic" "sns-alarm-topic" {
  name = "sns-out"
}

resource "aws_cloudwatch_metric_alarm" "sqs-queue-alarm" {
  for_each        = var.pipeline-queues
  actions_enabled = true
  alarm_actions = [
    data.aws_sns_topic.sns-alarm-topic.arn,
  ]
  alarm_name          = "${each.key}-empty-queue"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  threshold           = 1
  treat_missing_data  = "missing"

  dynamic "metric_query" {
    for_each = each.value

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