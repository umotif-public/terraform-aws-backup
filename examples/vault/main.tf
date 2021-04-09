provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

######
# KMS
######
data "aws_kms_key" "backup" {
  key_id = "alias/aws/backup"
}

data "aws_kms_key" "sns_backup" {
  key_id = "alias/aws/sns"
}

#########
# Backup
#########
module "backup" {
  source = "../.."

  # Create a vault
  vault_name        = "${var.name_prefix}-vault"
  vault_kms_key_arn = data.aws_kms_key.backup.arn

  # Create a backup plan
  plan_name = "${var.name_prefix}-backup-plan"

  rules = [
    {
      name              = "${var.name_prefix}-backup-rule"
      schedule          = "cron(0 12 * * ? *)"
      start_window      = "65"
      completion_window = "180"
      recovery_point_tags = {
        Project = "test"
        Region  = "eu-west-1"
      }

      lifecycle = {
        delete_after = 90
      }
    }
  ]

  selection_name = "${var.name_prefix}-backup-selection"

  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "Project"
      value = "Test"
    },
    {
      type  = "STRINGEQUALS"
      key   = "Environment"
      value = "test"
    }
  ]

  # Enable SNS Backup Notifications
  enable_sns_notifications = true
  vault_sns_kms_key_arn    = data.aws_kms_key.sns_backup.arn
  backup_vault_events = [
    "BACKUP_JOB_FAILED",
    "BACKUP_JOB_EXPIRED",
  ]

  tags = {
    Environment = "test"
  }
}
