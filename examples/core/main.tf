provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#####
# VPC and subnets
#####
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.62"

  name = "simple-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false

  tags = {
    Environment = "test"
  }
}

#############
# KMS key
#############
module "kms-rds" {
  source  = "umotif-public/kms/aws"
  version = "~> 1.0"

  alias_name              = "rds-kms-test-key"
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
            "Service" : ["rds.amazonaws.com", "monitoring.rds.amazonaws.com"]
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

module "kms-cloudwatch" {
  source  = "umotif-public/kms/aws"
  version = "~> 1.0"

  alias_name              = "cloudwatch-kms-test-key"
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
          "Effect" : "Allow",
          "Principal" : { "Service" : "logs.${data.aws_region.current.name}.amazonaws.com" },
          "Action" : [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
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

#############
# RDS Aurora
#############
module "aurora" {
  source = "umotif-public/rds-aurora/aws"

  name_prefix         = "example-aurora-mysql"
  database_name       = "databaseName"
  engine              = "aurora-mysql"
  engine_version      = "5.7.mysql_aurora.2.09.0"
  deletion_protection = false

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  kms_key_id = module.kms-rds.key_arn

  replica_count               = 1
  instance_type               = "db.t3.medium"
  apply_immediately           = true
  allow_major_version_upgrade = true
  skip_final_snapshot         = true

  iam_database_authentication_enabled = true

  enabled_cloudwatch_logs_exports = [
    {
      name              = "audit",
      retention_in_days = "60"
      kms_key_id        = module.kms-cloudwatch.key_arn
    },
    {
      name       = "error"
      kms_key_id = module.kms-cloudwatch.key_arn
    },
    {
      name              = "general",
      retention_in_days = "30"
    },
    {
      name = "slowquery",
    }
  ]

  allowed_cidr_blocks = ["10.10.0.0/24", "10.20.0.0/24", "10.30.0.0/24"]

  monitoring_interval = 60

  create_security_group = true

  cluster_tags = {
    "cluster_tags" = "example cluster main"
  }

  cluster_instance_tags = {
    "cluster_instance_tags" = "example of cluster instance tags"
  }

  tags = {
    Environment = "test"
  }
}

module "backup" {
  source = "../.."

  # Create a Vault
  enabled           = true
  vault_name        = "test-rds-aurora"
  vault_kms_key_arn = module.kms-backup.key_arn

  tags = {
    Environment = "test"
  }

  # Create a backup plan
  plan_name = "test-backup-plan"

  rules = [
    {
      name              = "test-backup-rule"
      target_vault_name = "test-rds-aurora"
      schedule          = "cron(0 12 * * ? *)"
      start_window      = "65"
      completion_window = "180"
      recovery_point_tags = {
        Project = "test"
        Region  = "eu-west-1"
      }

      lifecycle = {
        cold_storage_after = 1
        delete_after       = 92
      }

      copy_action = {
        destination_vault_arn = "arn:aws:backup:us-east-1:238957866604:backup-vault:Default"
        lifecycle = {
          copy_action_cold_storage_after = 0
          copy_action_delete_after       = 90
        }
      }
    }
  ]

  advanced_backup_settings = []

  selections = [
    {
      name = "test-backup-selection"
      resources = [
        module.aurora.rds_cluster_arn
      ]

      selection_tag = {
        type  = "STRINGEQUALS"
        key   = "Environment"
        value = "test"
      }
    }
  ]
}
