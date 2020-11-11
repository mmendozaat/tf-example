data "aws_iam_policy_document" "cloudwatch_kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::600913924980:root"]
      type        = "AWS"
    }
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid    = "allow_cloudwatch_kms"
    effect = "Allow"
    principals {
      identifiers = ["cloudwatch.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}