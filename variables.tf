variable "iam_role_name" {
  description = "Name of IAM Role to associate to the Backup Plan"
  type        = string
  default     = null
}

################
# AWS Backup plan
################
variable "plan_name" {
  description = "The display name of a backup plan"
  type        = string
}

variable "rules" {
  description = "A list of rules mapping rule configurations for a backup plan"
  type        = any
  default     = []
}

variable "selection_name" {
  description = "The display name of a resource selection document"
  type        = string
  default     = null
}

variable "selection_resources" {
  description = "A list of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan"
  type        = list(string)
  default     = []
}

variable "selection_tags" {
  description = "A list of selection tags map"
  type        = list(any)
  default     = []
}

variable "advanced_backup_settings" {
  description = "An object that specifies backup options for each resource type"
  type        = any
  default     = []
}

#################
# AWS Backup vault
#################
variable "vault_name" {
  description = "Name of the backup vault to create. If not given, AWS use default"
  type        = string
  default     = null
}

variable "vault_kms_key_arn" {
  description = "The server-side encryption key that is used to protect your backups"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "vault_force_destroy" {
  description = "A boolean that indicates that all recovery points stored in the vault are deleted so that the vault can be destroyed without error."
  type        = bool
  default     = false
}


################
# AWS Backup SNS Notifications
################
variable "enable_sns_notifications" {
  description = "Enable Backup Vault Notifications"
  type        = bool
  default     = false
}

variable "create_sns_topic" {
  description = "Create SNS Topic"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "The Amazon Resource Name (ARN) that specifies the topic for a backup vault’s events"
  type        = string
  default     = null
}

variable "vault_sns_kms_key_arn" {
  description = "The server-side encryption key that is used to protect SNS messages for backups"
  type        = string
  default     = null
}

variable "backup_vault_events" {
  description = "An array of events that indicate the status of jobs to back up resources to the backup vault."
  type        = list(string)
  default = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_SUCCESSFUL",
    "BACKUP_JOB_FAILED",
    "BACKUP_JOB_EXPIRED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_SUCCESSFUL",
    "RESTORE_JOB_FAILED",
    "COPY_JOB_STARTED",
    "COPY_JOB_SUCCESSFUL",
    "COPY_JOB_FAILED",
    "RECOVERY_POINT_MODIFIED",
    "BACKUP_PLAN_CREATED",
    "BACKUP_PLAN_MODIFIED"
  ]
}
