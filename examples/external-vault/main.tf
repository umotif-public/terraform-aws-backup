provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

######
# KMS
######
module "kms-backup" {
  source  = "umotif-public/kms/aws"
  version = "~> 1.0"

  alias_name              = "backup-kms-test-key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Enable IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
              data.aws_caller_identity.current.arn
            ]
          },
          "Action" : "kms:*",
          "Resource" : "*"
        },
        {
          "Sid" : "Allow use of the key",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : ["backup.amazonaws.com"]
          },
          "Action" : [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ],
          "Resource" : "*"
        }
      ]
    }
  )

  tags = {
    Environment = "test"
  }
}

#########
# Backup
#########
resource "aws_backup_vault" "external_vault" {
  name        = "external-test"
  kms_key_arn = module.kms-backup.key_arn
  tags = {
    Enviroment = "test"
    Vault      = "external"
  }
}

module "backup" {
  source = "../.."

  # Create a backup plan
  plan_name = "test-backup-plan"

  rules = [
    {
      name              = "test-backup-rule"
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
        delete_after       = 90
      }
    }
  ]

  selections = [
    {
      name = "test-backup-selection"
      selection_tag = {
        type  = "STRINGEQUALS"
        key   = "Environment"
        value = "test"
      }
    }
  ]

  tags = {
    Environment = "test"
  }
}