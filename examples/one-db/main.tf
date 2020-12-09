provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#####
# VPC and subnets
#####
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.all.ids
  id       = each.value
}

#############
# KMS key
#############
data "aws_iam_policy_document" "rds" {
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
    sid = "AllowBasicActionsRDSservices"

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
        "rds.amazonaws.com",
        "monitoring.rds.amazonaws.com"
      ]
    }
  }
}

module "kms_rds" {
  source  = "umotif-public/kms/aws"
  version = "~> 1.0.2"

  alias_name              = "${var.name_prefix}-rds"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.rds.json

  tags = {
    Environment = "test"
  }
}

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

#############
# RDS Aurora
#############
module "aurora" {
  source = "umotif-public/rds-aurora/aws"

  name_prefix   = "${var.name_prefix}-aurora-mysql"
  database_name = "${var.name_prefix}mysqldb"
  engine        = "aurora-mysql"

  vpc_id  = data.aws_vpc.default.id
  subnets = data.aws_subnet_ids.all.ids

  kms_key_id = module.kms_rds.key_arn

  instance_type = "db.t3.medium"

  allowed_cidr_blocks = [for s in data.aws_subnet.example : s.cidr_block]

  tags = {
    Environment = "test"
  }
}

#########
# Backup
#########
module "backup" {
  source = "../.."

  # Create a Vault
  vault_name        = "${var.name_prefix}-rds-aurora"
  vault_kms_key_arn = module.kms_backup.key_arn

  tags = {
    Environment = "test"
  }

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
        cold_storage_after = 0
        delete_after       = 90
      }
    }
  ]

  selection_name      = "${var.name_prefix}-backup-selection"
  selection_resources = [module.aurora.rds_cluster_arn]

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
}
