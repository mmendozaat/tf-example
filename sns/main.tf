resource "aws_sns_topic" "sns-alarm-topic" {
  name = "sns-out-${var.sns_name_suffix}"
  kms_master_key_id = "alias/sns_key"
}

output "topic_arn" {
    value = aws_sns_topic.sns-alarm-topic.arn
}