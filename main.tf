#####
# Backup Vault
#####
resource "aws_backup_vault" "main" {
  count = var.vault_name != null ? 1 : 0

  name        = var.vault_name
  kms_key_arn = var.vault_kms_key_arn
  tags        = var.tags
}

#####
# Backup Plan
#####
resource "aws_backup_plan" "main" {
  name = var.plan_name

  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name                = lookup(rule.value, "name")
      target_vault_name        = var.vault_name != null ? aws_backup_vault.main[0].name : lookup(rule.value, "target_vault_name", "Default")
      schedule                 = lookup(rule.value, "schedule", null)
      start_window             = lookup(rule.value, "start_window", null)
      completion_window        = lookup(rule.value, "completion_window", null)
      enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", false)
      recovery_point_tags      = length(lookup(rule.value, "recovery_point_tags")) == 0 ? var.tags : lookup(rule.value, "recovery_point_tags")

      dynamic "lifecycle" {
        for_each = length(lookup(rule.value, "lifecycle")) == 0 ? [] : [lookup(rule.value, "lifecycle", {})]
        content {
          cold_storage_after = lookup(lifecycle.value, "cold_storage_after", 0)
          delete_after       = lookup(lifecycle.value, "delete_after", 90)
        }
      }

      dynamic "copy_action" {
        for_each = length(lookup(rule.value, "copy_action", {})) == 0 ? [] : [lookup(rule.value, "copy_action", {})]
        content {
          destination_vault_arn = lookup(copy_action.value, "destination_vault_arn", null)

          dynamic "lifecycle" {
            for_each = length(lookup(copy_action.value, "lifecycle", {})) == 0 ? [] : [lookup(copy_action.value, "lifecycle", {})]
            content {
              cold_storage_after = lookup(lifecycle.value, "copy_action_cold_storage_after", 0)
              delete_after       = lookup(lifecycle.value, "copy_action_delete_after", 90)
            }
          }
        }
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.advanced_backup_settings
    content {
      resource_type  = lookup(advanced_backup_setting.value, "resource_type", "EC2")
      backup_options = lookup(advanced_backup_setting.value, "backup_options", null)
    }
  }

  tags = var.tags
}

#####
# Backup Selection
#####
resource "aws_backup_selection" "main" {
  iam_role_arn = aws_iam_role.main.arn
  name         = var.selection_name
  plan_id      = aws_backup_plan.main.id

  resources = var.selection_resources

  dynamic "selection_tag" {
    for_each = var.selection_tags
    content {
      type  = lookup(selection_tag.value, "type", null)
      key   = lookup(selection_tag.value, "key", null)
      value = lookup(selection_tag.value, "value", null)
    }
  }
}

#######
# SNS Backup Notifications
#######
resource "aws_sns_topic" "main" {
  count = var.sns_topic_arn != null ? 0 : 1

  name              = var.vault_name != null ? "${aws_backup_vault.main[0].name}-events" : "backup-vault-events"
  kms_master_key_id = var.vault_sns_kms_key_arn
}

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

    resources = var.sns_topic_arn != null ? [var.sns_topic_arn] : [aws_sns_topic.main[0].arn]
  }
}

resource "aws_sns_topic_policy" "main" {
  count = var.enable_sns_notifications ? 1 : 0

  arn    = var.sns_topic_arn != null ? var.sns_topic_arn : aws_sns_topic.main[0].arn
  policy = data.aws_iam_policy_document.sns_policy[0].json
}

resource "aws_backup_vault_notifications" "main" {
  count = var.enable_sns_notifications ? 1 : 0

  backup_vault_name   = var.vault_name != null ? aws_backup_vault.main[0].name : "Default"
  sns_topic_arn       = var.sns_topic_arn != null ? var.sns_topic_arn : aws_sns_topic.main[0].arn
  backup_vault_events = var.backup_vault_events
}

#####
# IAM Role
#####
resource "aws_iam_role" "main" {
  name               = var.iam_role_name != null ? var.iam_role_name : "aws-backup-plan-${var.plan_name}-role"
  assume_role_policy = data.aws_iam_policy_document.main.json

  tags = var.tags
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

resource "aws_iam_role_policy_attachment" "main_role_policy_attach" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.main.name
}

resource "aws_iam_policy" "main_custom_policy" {
  description = "AWS Backup Tag policy"

  policy = data.aws_iam_policy_document.main_custom_policy.json
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

resource "aws_iam_role_policy_attachment" "main_custom_policy_attach" {
  policy_arn = aws_iam_policy.main_custom_policy.arn
  role       = aws_iam_role.main.name
}
