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

resource "aws_kms_key" "sns_key" {
  description = "sns key"
  policy      = data.aws_iam_policy_document.cloudwatch_kms.json
}

module "snsq" {
  source          = "./sns"
  sns_name_suffix = "q"
}

module "snsa" {
  source          = "./sns"
  sns_name_suffix = "a"
}

module "snsb" {
  source          = "./sns"
  sns_name_suffix = "b"
}

module "cloudwatchq" {
  source        = "./cloudwatch"
  queues        = ["q1.fifo", "q2.fifo"]
  pipeline      = "q"
  sns_topic_arn = module.snsq.topic_arn
}

module "cloudwatcha" {
  source        = "./cloudwatch"
  queues        = ["a1.fifo", "a2.fifo"]
  pipeline      = "a"
  sns_topic_arn = module.snsa.topic_arn
}

module "cloudwatchb" {
  source        = "./cloudwatch"
  queues        = ["b1.fifo", "b2.fifo"]
  pipeline      = "b"
  sns_topic_arn = module.snsb.topic_arn
}