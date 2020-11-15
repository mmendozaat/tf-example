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
  sns_key_id      = aws_kms_key.sns_key.key_id
}

module "snsa" {
  source          = "./sns"
  sns_name_suffix = "a"
  sns_key_id      = aws_kms_key.sns_key.key_id
}

module "snsb" {
  source          = "./sns"
  sns_name_suffix = "b"
  sns_key_id      = aws_kms_key.sns_key.key_id
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

resource "aws_glue_job" "ticker_analytics" {
  connections = []
  default_arguments = {
    "--TempDir"             = "s3://aws-glue-temporary-600913924980-us-east-1/admin"
    "--class"               = "GlueApp"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--job-language"        = "scala"
  }
  glue_version              = "2.0"
  max_retries               = 0
  name                      = "ticker_analytics"
  non_overridable_arguments = {}
  number_of_workers         = 3
  role_arn                  = "arn:aws:iam::600913924980:role/service-role/AWSGlueServiceRole-demo"
  tags                      = {}
  timeout                   = 2880

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://aws-glue-scripts-600913924980-us-east-1/admin/ticker_analytics"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}

resource "aws_glue_trigger" "ta1" {
  enabled = true
  name    = "ta1"
  tags    = {}
  type    = "ON_DEMAND"

  actions {
    arguments = {
      "--PARAM" = "1"
    }
    job_name = "ticker_analytics"
    timeout  = 2880
  }

  timeouts {}
}