provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

######
# KMS
######
data "aws_iam_policy_document" "backup" {
  statement {
    sid = "EnableAllActionsIAM"

    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        data.aws_caller_identity.current.arn
      ]
    }
  }

  statement {
    sid = "AllowBasicActionsBackupService"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "backup.amazonaws.com"
      ]
    }
  }
}

module "kms_backup" {
  source  = "umotif-public/kms/aws"
  version = "~> 1.0.2"

  alias_name              = "${var.name_prefix}-backup"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.backup.json

  tags = {
    Environment = "test"
  }
}

#########
# Backup
#########
resource "aws_backup_vault" "external_vault" {
  name        = "${var.name_prefix}-external"
  kms_key_arn = module.kms_backup.key_arn
  tags = {
    Enviroment = "test"
    Vault      = "external"
  }
}

module "backup" {
  source = "../.."

  # Create a backup plan
  plan_name = "${var.name_prefix}-backup-plan"

  rules = [
    {
      name              = "${var.name_prefix}-backup-rule"
      target_vault_name = aws_backup_vault.external_vault.name
      schedule          = "cron(0 12 * * ? *)"
      start_window      = "65"
      completion_window = "180"
      recovery_point_tags = {
        Project = "test"
        Region  = "eu-west-1"
      }

      lifecycle = {
        cold_storage_after = 0
        delete_after       = 95
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

  tags = {
    Environment = "test"
  }

  depends_on = [aws_backup_vault.external_vault]
}
