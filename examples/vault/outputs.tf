output "backup_vault_id" {
  description = "The name of the AWS Backup Vault"
  value       = module.backup.backup_vault_id
}

output "backup_vault_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the AWS Backup Vault"
  value       = module.backup.backup_vault_arn
}

output "backup_vault_recovery_points" {
  description = "The number of recovery points that are stored in a backup vault"
  value       = module.backup.backup_vault_recovery_points
}

output "backup_plan_id" {
  description = "The name of the backup plan"
  value       = module.backup.backup_plan_id
}

output "backup_plan_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the backup plan"
  value       = module.backup.backup_plan_arn
}

output "backup_plan_version" {
  description = "Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan."
  value       = module.backup.backup_plan_version
}

output "backup_selection_id" {
  description = "The identifier of the backup selection"
  value       = module.backup.backup_selection_id
}