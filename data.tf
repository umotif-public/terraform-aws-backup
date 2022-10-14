data "aws_partition" "current" {}

data "aws_iam_policy_document" "sns_policy" {
  count = var.enable_sns_notifications ? 1 : 0

  statement {
    sid = "AllowSNSPublish"

    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "backup.amazonaws.com"
      ]
    }

    resources = var.create_sns_topic ? [aws_sns_topic.main[0].arn] : [var.sns_topic_arn]
  }
}

data "aws_iam_policy_document" "main" {
  statement {
    sid = "AllowBackupService"

    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "backup.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "main_custom_policy" {
  statement {
    sid = "AllowTaggingResources"

    actions = [
      "backup:TagResource",
      "backup:ListTags",
      "backup:UntagResource",
      "tag:GetResources"
    ]

    resources = ["*"]
  }
}