# terraform-aws-backup
Terraform module to provision AWS Backup resources

## Terraform versions

Terraform 0.13. Pin module version to `~> v1.0`. Submit pull-requests to `master` branch.

## Usage

```hcl
module "backup" {
  source = "umotif-public/backup/aws"
  version = "~> 1.0.0"

  vault_name        = "test-rds-aurora"
  vault_kms_key_arn = "arn:aws:kms:eu-west-1:1111111111:key/07a8a813-fcc9-4d7f-a982648d9c25"

  tags = {
    Environment = "test"
  }

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
        cold_storage_after = 0
        delete_after       = 90
      }
    }
  ]

  selections = [
    {
      name = "test-backup-selection"
      resources = [
        "arn:aws:rds:eu-west-1:1111111111:cluster:example-database-1"
      ]

      selection_tag = {
        type  = "STRINGEQUALS"
        key   = "Environment"
        value = "test"
      }
    }
  ]
}
```

## Assumptions

Module is to be used with Terraform > 0.13.

## Examples

* [Backup with Aurora MySQL](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/core)
* [Backup with Aurora MySQL and Aurora PostgreSQL](https://github.com/umotif-public/terraform-aws-backup/tree/master/examples/multiple-dbs)

## Authors

Module managed by [Marcin Cuber](https://github.com/marcincuber) [LinkedIn](https://www.linkedin.com/in/marcincuber/) and [Abdul Wahid](https://github.com/Ohid25) [LinkedIn](https://www.linkedin.com/in/abdul-wahid/).

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| advanced\_backup\_settings | An object that specifies backup options for each resource type | `any` | `[]` | no |
| iam\_role\_name | Name of IAM Role to associate to the Backup Plan | `string` | `null` | no |
| plan\_name | The display name of a backup plan | `string` | n/a | yes |
| rule\_completion\_window | The amount of time AWS Backup attempts a backup before canceling the job and returning an error | `number` | `null` | no |
| rule\_copy\_action\_destination\_vault\_arn | An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup. | `string` | `null` | no |
| rule\_copy\_action\_lifecycle | The lifecycle defines when a protected resource is copied over to a backup vault and when it expires. | `map` | `{}` | no |
| rule\_lifecycle\_cold\_storage\_after | Specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| rule\_lifecycle\_delete\_after | Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after` | `number` | `null` | no |
| rule\_name | An display name for a backup rule | `string` | `null` | no |
| rule\_recovery\_point\_tags | Metadata that you can assign to help organize the resources that you create | `map(string)` | `{}` | no |
| rule\_schedule | A CRON expression specifying when AWS Backup initiates a backup job | `string` | `null` | no |
| rule\_start\_window | The amount of time in minutes before beginning a backup | `number` | `null` | no |
| rules | A list of rules mapping rule configurations for a backup plan | `any` | `[]` | no |
| selection\_name | The display name of a resource selection document | `string` | `null` | no |
| selection\_resources | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list` | `[]` | no |
| selection\_tag\_key | The key in a key-value pair | `string` | `null` | no |
| selection\_tag\_type | An operation, such as StringEquals, that is applied to a key-value pair used to filter resources in a selection | `string` | `null` | no |
| selection\_tag\_value | The value in a key-value pair | `string` | `null` | no |
| selections | A list of selection maps | `list` | `[]` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| vault\_kms\_key\_arn | The server-side encryption key that is used to protect your backups | `string` | `null` | no |
| vault\_name | Name of the backup vault to create. If not given, AWS use default | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| backup\_plan\_arn | The Amazon Resource Name (ARN) that identifies the backup plan |
| backup\_plan\_id | The name of the backup plan |
| backup\_plan\_version | Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan. |
| backup\_selection\_id | The identifier of the backup selection |
| backup\_vault\_arn | The Amazon Resource Name (ARN) that identifies the AWS Backup Vault |
| backup\_vault\_id | The name of the AWS Backup Vault |
| backup\_vault\_recovery\_points | The number of recovery points that are stored in a backup vault |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

See LICENSE for full details.

## Pre-commit hooks

### Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/segmentio/terraform-docs) required for `terraform_docs` hooks.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.

#### MacOS

```bash
brew install pre-commit terraform-docs tflint

brew tap git-chglog/git-chglog
brew install git-chglog
```
