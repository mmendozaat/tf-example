resource "aws_sqs_queue" "queue1" {
  content_based_deduplication       = false
  delay_seconds                     = 60
  fifo_queue                        = true
  message_retention_seconds         = 43200
  name                              = "q1.fifo"
  receive_wait_time_seconds  = 20
  tags                       = {}
  visibility_timeout_seconds = 900
}

resource "aws_sqs_queue" "queue2" {
  content_based_deduplication       = false
  delay_seconds                     = 60
  fifo_queue                        = true
  message_retention_seconds         = 43200
  name                              = "q2.fifo"
  receive_wait_time_seconds  = 20
  tags                       = {}
  visibility_timeout_seconds = 900
}

resource "aws_sqs_queue" "fromsns" {
  content_based_deduplication       = false
  delay_seconds                     = 60
  fifo_queue                        = true
  message_retention_seconds         = 43200
  name                              = "fromsns.fifo"
  receive_wait_time_seconds  = 20
  tags                       = {}
  visibility_timeout_seconds = 900
}

resource "aws_sns_topic" "alarm-topic" {
    name   = "alarm.fifo"
}

resource "aws_cloudwatch_metric_alarm" "sqs-queue-alarm" {
  alarm_name          = "empty-queue"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  period = 300
}
