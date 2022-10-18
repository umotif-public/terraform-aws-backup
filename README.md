[![GitHub release (latest by date)](https://img.shields.io/github/v/release/umotif-public/terraform-aws-backup)](https://github.com/umotif-public/terraform-aws-backup/releases/latest)
[![Lint and Validate](https://github.com/umotif-public/terraform-aws-backup/workflows/Lint%20and%20Validate/badge.svg)](https://github.com/umotif-public/terraform-aws-backup/actions?query=workflow%3A%22Lint+and+Validate%22)
[![Terratest](https://github.com/umotif-public/terraform-aws-backup/workflows/Terratest/badge.svg)](https://github.com/umotif-public/terraform-aws-backup/actions?query=workflow%3ATerratest)

# Terraform AWS Backup

Terraform module to provision [AWS Backup](https://aws.amazon.com/backup/) resources.

## Terraform versions

Terraform 1.0+. Pin module version to `~> v1.5`. Submit pull-requests to `main` branch. Prior versions on `master` branch will need `~> v1.3`.

## Usage

**If referring directly to the code instead of a pinned version, take note that from release 1.4.0 all future changes will only be made to the main branch.**

```hcl
module "backup" {
  source = "umotif-public/backup/aws"
  version = "~> 1.5"

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

Module is to be used with Terraform > 1.0.

## Examples

* [Backup with Aurora MySQL](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/one-db)
* [Backup with Aurora MySQL and Aurora PostgreSQL](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/multiple-dbs)
* [Backup with an externally created Vault](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/external-vault)
* [Backup with Vault only](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/vault)

## Authors

Module managed by:

* Module managed by [uMotif](https://github.com/umotif-public/).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_notifications.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications) | resource |
| [aws_iam_policy.main_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.main_custom_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.main_role_backup_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.main_role_restore_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sns_topic.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.main_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_backup_settings"></a> [advanced\_backup\_settings](#input\_advanced\_backup\_settings) | An object that specifies backup options for each resource type | `any` | `[]` | no |
| <a name="input_backup_vault_events"></a> [backup\_vault\_events](#input\_backup\_vault\_events) | An array of events that indicate the status of jobs to back up resources to the backup vault. | `list(string)` | <pre>[<br>  "BACKUP_JOB_STARTED",<br>  "BACKUP_JOB_COMPLETED",<br>  "BACKUP_JOB_SUCCESSFUL",<br>  "BACKUP_JOB_FAILED",<br>  "BACKUP_JOB_EXPIRED",<br>  "RESTORE_JOB_STARTED",<br>  "RESTORE_JOB_COMPLETED",<br>  "RESTORE_JOB_SUCCESSFUL",<br>  "RESTORE_JOB_FAILED",<br>  "COPY_JOB_STARTED",<br>  "COPY_JOB_SUCCESSFUL",<br>  "COPY_JOB_FAILED",<br>  "RECOVERY_POINT_MODIFIED",<br>  "BACKUP_PLAN_CREATED",<br>  "BACKUP_PLAN_MODIFIED"<br>]</pre> | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Create SNS Topic | `bool` | `true` | no |
| <a name="input_enable_sns_notifications"></a> [enable\_sns\_notifications](#input\_enable\_sns\_notifications) | Enable Backup Vault Notifications | `bool` | `false` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of IAM Role to associate to the Backup Plan | `string` | `null` | no |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | The display name of a backup plan | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | A list of rules mapping rule configurations for a backup plan | `any` | `[]` | no |
| <a name="input_selection_name"></a> [selection\_name](#input\_selection\_name) | The display name of a resource selection document | `string` | `null` | no |
| <a name="input_selection_resources"></a> [selection\_resources](#input\_selection\_resources) | A list of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list(string)` | `[]` | no |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | A list of selection tags map | `list(any)` | `[]` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The Amazon Resource Name (ARN) that specifies the topic for a backup vault’s events | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_vault_force_destroy"></a> [vault\_force\_destroy](#input\_vault\_force\_destroy) | A boolean that indicates that all recovery points stored in the vault are deleted so that the vault can be destroyed without error. | `bool` | `false` | no |
| <a name="input_vault_kms_key_arn"></a> [vault\_kms\_key\_arn](#input\_vault\_kms\_key\_arn) | The server-side encryption key that is used to protect your backups | `string` | `null` | no |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | Name of the backup vault to create. If not given, AWS use default | `string` | `null` | no |
| <a name="input_vault_sns_kms_key_arn"></a> [vault\_sns\_kms\_key\_arn](#input\_vault\_sns\_kms\_key\_arn) | The server-side encryption key that is used to protect SNS messages for backups | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_arn"></a> [backup\_plan\_arn](#output\_backup\_plan\_arn) | The Amazon Resource Name (ARN) that identifies the backup plan |
| <a name="output_backup_plan_id"></a> [backup\_plan\_id](#output\_backup\_plan\_id) | The name of the backup plan |
| <a name="output_backup_plan_version"></a> [backup\_plan\_version](#output\_backup\_plan\_version) | Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan. |
| <a name="output_backup_selection_id"></a> [backup\_selection\_id](#output\_backup\_selection\_id) | The identifier of the backup selection |
| <a name="output_backup_sns_topic_arn"></a> [backup\_sns\_topic\_arn](#output\_backup\_sns\_topic\_arn) | The Amazon Resource Name (ARN) that specifies the topic for a backup vault’s events |
| <a name="output_backup_vault_arn"></a> [backup\_vault\_arn](#output\_backup\_vault\_arn) | The Amazon Resource Name (ARN) that identifies the AWS Backup Vault |
| <a name="output_backup_vault_events"></a> [backup\_vault\_events](#output\_backup\_vault\_events) | An array of events that indicate the status of jobs to back up resources to the backup vault. |
| <a name="output_backup_vault_iam_role_arn"></a> [backup\_vault\_iam\_role\_arn](#output\_backup\_vault\_iam\_role\_arn) | The ARN of the backup IAM role |
| <a name="output_backup_vault_iam_role_name"></a> [backup\_vault\_iam\_role\_name](#output\_backup\_vault\_iam\_role\_name) | The name of the backup IAM role |
| <a name="output_backup_vault_id"></a> [backup\_vault\_id](#output\_backup\_vault\_id) | The name of the AWS Backup Vault |
| <a name="output_backup_vault_recovery_points"></a> [backup\_vault\_recovery\_points](#output\_backup\_vault\_recovery\_points) | The number of recovery points that are stored in a backup vault |
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
