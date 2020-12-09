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

data "aws_subnet" "public" {
  for_each = data.aws_subnet_ids.all.ids
  id       = each.value
}

#############
# KMS key
#############
data "aws_kms_key" "backup" {
  key_id = "alias/aws/backup"
}

data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}

#############
# RDS Aurora
#############
module "aurora-mysql" {
  source = "umotif-public/rds-aurora/aws"

  name_prefix   = "${var.name_prefix}-aurora-mysql"
  database_name = "${var.name_prefix}mysqldb"
  engine        = "aurora-mysql"

  vpc_id  = data.aws_vpc.default.id
  subnets = data.aws_subnet_ids.all.ids

  kms_key_id = data.aws_kms_key.rds.arn

  instance_type = "db.t3.medium"

  allowed_cidr_blocks = [for s in data.aws_subnet.public : s.cidr_block]

  tags = {
    Environment = "test"
  }
}

module "aurora-postgresql" {
  source = "umotif-public/rds-aurora/aws"

  name_prefix             = "${var.name_prefix}-postgresql"
  database_name           = "${var.name_prefix}postgresqldb"
  engine                  = "aurora-postgresql"
  engine_version          = "11.8"
  engine_parameter_family = "aurora-postgresql11"

  vpc_id  = data.aws_vpc.default.id
  subnets = data.aws_subnet_ids.all.ids

  kms_key_id = data.aws_kms_key.rds.arn

  instance_type = "db.t3.medium"

  allowed_cidr_blocks = [for s in data.aws_subnet.public : s.cidr_block]

  tags = {
    Environment = "test"
  }
}

#############
# Backup
#############
module "backup" {
  source = "../.."

  # Create a Vault
  vault_name        = "${var.name_prefix}-rds-aurora"
  vault_kms_key_arn = data.aws_kms_key.backup.arn

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
      completion_window = "190"
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

  selection_name = "${var.name_prefix}-backup-selection"
  selection_resources = [
    module.aurora-mysql.rds_cluster_arn,
    module.aurora-postgresql.rds_cluster_arn
  ]

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
