[![GitHub release (latest by date)](https://img.shields.io/github/v/release/umotif-public/terraform-aws-backup)](https://github.com/umotif-public/terraform-aws-backup/releases/latest)
[![Lint and Validate](https://github.com/umotif-public/terraform-aws-backup/workflows/Lint%20and%20Validate/badge.svg)](https://github.com/umotif-public/terraform-aws-backup/actions?query=workflow%3A%22Lint+and+Validate%22)
[![Terratest](https://github.com/umotif-public/terraform-aws-backup/workflows/Terratest/badge.svg)](https://github.com/umotif-public/terraform-aws-backup/actions?query=workflow%3ATerratest)


# Terraform AWS Backup

Terraform module to provision [AWS Backup](https://aws.amazon.com/backup/) resources.

## Terraform versions

Terraform 0.13. Pin module version to `~> v1.0`. Submit pull-requests to `master` branch.

## Usage

```hcl
module "backup" {
  source = "umotif-public/backup/aws"
  version = "~> 1.0"

  vault_name        = "test-rds-aurora"
  vault_kms_key_arn = "arn:aws:kms:eu-west-1:1111111111:key/07a8a813-fcc9-4d7f-a982648d9c25"

  tags = {
    Environment = "test"
  }

  plan_name = "test-backup-plan"

  rules = [
    {
      name              = "test-backup-rule"
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

  selection_name = "test-backup-selection"
  selection_resources = ["arn:aws:rds:eu-west-1:1111111111:cluster:example-database-1"]

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
```

## Assumptions

Module is to be used with Terraform > 0.13.

## Examples

* [Backup with Aurora MySQL](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/one-db)
* [Backup with Aurora MySQL and Aurora PostgreSQL](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/multiple-dbs)
* [Backup with an externally created Vault](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/external-vault)
* [Backup with Vault only](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/vault)

## Authors

Module managed by:

* [Marcin Cuber](https://github.com/marcincuber) ([LinkedIn](https://www.linkedin.com/in/marcincuber/))
* [Abdul Wahid](https://github.com/Ohid25) ([LinkedIn](https://www.linkedin.com/in/abdul-wahid/))

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.11 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.11 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_backup_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) |
| [aws_backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) |
| [aws_backup_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) |
| [aws_backup_vault_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) |
| [aws_sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| advanced\_backup\_settings | An object that specifies backup options for each resource type | `any` | `[]` | no |
| backup\_vault\_events | An array of events that indicate the status of jobs to back up resources to the backup vault. | `list(string)` | <pre>[<br>  "BACKUP_JOB_STARTED",<br>  "BACKUP_JOB_COMPLETED",<br>  "BACKUP_JOB_SUCCESSFUL",<br>  "BACKUP_JOB_FAILED",<br>  "BACKUP_JOB_EXPIRED",<br>  "RESTORE_JOB_STARTED",<br>  "RESTORE_JOB_COMPLETED",<br>  "RESTORE_JOB_SUCCESSFUL",<br>  "RESTORE_JOB_FAILED",<br>  "COPY_JOB_STARTED",<br>  "COPY_JOB_SUCCESSFUL",<br>  "COPY_JOB_FAILED",<br>  "RECOVERY_POINT_MODIFIED",<br>  "BACKUP_PLAN_CREATED",<br>  "BACKUP_PLAN_MODIFIED"<br>]</pre> | no |
| enable\_sns\_notifications | Enable Backup Vault Notifications | `bool` | `false` | no |
| iam\_role\_name | Name of IAM Role to associate to the Backup Plan | `string` | `null` | no |
| plan\_name | The display name of a backup plan | `string` | n/a | yes |
| rules | A list of rules mapping rule configurations for a backup plan | `any` | `[]` | no |
| selection\_name | The display name of a resource selection document | `string` | `null` | no |
| selection\_resources | A list of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list(string)` | `[]` | no |
| selection\_tags | A list of selection tags map | `list(any)` | `[]` | no |
| sns\_topic\_arn | The Amazon Resource Name (ARN) that specifies the topic for a backup vault’s events | `string` | `null` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| vault\_kms\_key\_arn | The server-side encryption key that is used to protect your backups | `string` | `null` | no |
| vault\_name | Name of the backup vault to create. If not given, AWS use default | `string` | `null` | no |
| vault\_sns\_kms\_key\_arn | The server-side encryption key that is used to protect SNS messages for backups | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| backup\_plan\_arn | The Amazon Resource Name (ARN) that identifies the backup plan |
| backup\_plan\_id | The name of the backup plan |
| backup\_plan\_version | Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan. |
| backup\_selection\_id | The identifier of the backup selection |
| backup\_sns\_topic\_arn | The Amazon Resource Name (ARN) that specifies the topic for a backup vault’s events |
| backup\_vault\_arn | The Amazon Resource Name (ARN) that identifies the AWS Backup Vault |
| backup\_vault\_events | An array of events that indicate the status of jobs to back up resources to the backup vault. |
| backup\_vault\_id | The name of the AWS Backup Vault |
| backup\_vault\_recovery\_points | The number of recovery points that are stored in a backup vault |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

See LICENSE for full details.

## Pre-commit hooks & Golang for Terratest

### Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/segmentio/terraform-docs) required for `terraform_docs` hooks.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.
* [`golang`](https://formulae.brew.sh/formula/go) required for running tests.

#### Terratest

We are using [Terratest](https://terratest.gruntwork.io/) to run tests on this module.

```bash
brew install go
# Change to test directory
cd test
# Get dependencies
go mod download
# Run tests
go test -v -timeout 30m
```

#### MacOS

```bash
brew install pre-commit terraform-docs tflint

brew tap git-chglog/git-chglog
brew install git-chglog
```
