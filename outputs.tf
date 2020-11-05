#####
# AWS Backup Vault Outputs
#####
output "backup_vault_id" {
  description = "The name of the AWS Backup Vault"
  value       = aws_backup_vault.main[0].id
}

output "backup_vault_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the AWS Backup Vault"
  value       = aws_backup_vault.main[0].arn
}

output "backup_vault_recovery_points" {
  description = "The number of recovery points that are stored in a backup vault"
  value       = aws_backup_vault.main[0].recovery_points
}

#####
# AWS Backup Plan Outputs
#####

output "backup_plan_id" {
  description = "The name of the backup plan"
  value       = aws_backup_plan.main.id
}

output "backup_plan_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the backup plan"
  value       = aws_backup_plan.main.arn
}

output "backup_plan_version" {
  description = "Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan."
  value       = aws_backup_plan.main.version
}

#####
# AWS Backup Selection Outputs
####

output "backup_selection_id" {
  description = "The identifier of the backup selection"
  value       = aws_backup_selection.main[*].id
}
