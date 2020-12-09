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

#########
# Backup
#########
resource "aws_backup_vault" "external_vault" {
  name        = "${var.name_prefix}-external"
  kms_key_arn = data.aws_kms_key.backup.arn
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
