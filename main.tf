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
      rule_name           = lookup(rule.value, "name")
      target_vault_name   = lookup(rule.value, "target_vault_name", null) == null ? var.vault_name : lookup(rule.value, "target_vault_name", "Default")
      schedule            = lookup(rule.value, "schedule", null)
      start_window        = lookup(rule.value, "start_window", null)
      completion_window   = lookup(rule.value, "completion_window", null)
      recovery_point_tags = length(lookup(rule.value, "recovery_point_tags")) == 0 ? var.tags : lookup(rule.value, "recovery_point_tags")

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

  depends_on = [var.vault_name]
}

#####
# Backup Selection
#####
resource "aws_backup_selection" "main" {
  count = length(var.selections) >= 1 ? length(var.selections) : 0

  iam_role_arn = aws_iam_role.main.arn
  name         = lookup(element(var.selections, count.index), "name", null)
  plan_id      = aws_backup_plan.main.id

  resources = lookup(element(var.selections, count.index), "resources", null)

  dynamic "selection_tag" {
    for_each = length(lookup(element(var.selections, count.index), "selection_tag", {})) == 0 ? [] : [lookup(element(var.selections, count.index), "selection_tag", {})]
    content {
      type  = lookup(selection_tag.value, "type", null)
      key   = lookup(selection_tag.value, "key", null)
      value = lookup(selection_tag.value, "value", null)
    }
  }
}

#####
# IAM Role
#####
resource "aws_iam_role" "main" {
  name               = var.iam_role_name != null ? var.iam_role_name : "aws-backup-plan-${var.plan_name}-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "main_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.main.name
}

resource "aws_iam_policy" "main_custom_policy" {
  description = "AWS Backup Tag policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowTaggingResources",
      "Effect": "Allow",
      "Action": [
        "backup:TagResource",
        "backup:ListTags",
        "backup:UntagResource",
        "tag:GetResources"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main_custom_policy_attach" {
  policy_arn = aws_iam_policy.main_custom_policy.arn
  role       = aws_iam_role.main.name
}
