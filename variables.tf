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

variable "rule_name" {
  description = "An display name for a backup rule"
  type        = string
  default     = null
}

variable "rule_schedule" {
  description = "A CRON expression specifying when AWS Backup initiates a backup job"
  type        = string
  default     = null
}

variable "rule_start_window" {
  description = "The amount of time in minutes before beginning a backup"
  type        = number
  default     = null
}

variable "rule_completion_window" {
  description = "The amount of time AWS Backup attempts a backup before canceling the job and returning an error"
  type        = number
  default     = null
}

variable "rule_recovery_point_tags" {
  description = "Metadata that you can assign to help organize the resources that you create"
  type        = map(string)
  default     = {}
}

variable "rule_lifecycle_cold_storage_after" {
  description = "Specifies the number of days after creation that a recovery point is moved to cold storage"
  type        = number
  default     = null
}

variable "rule_lifecycle_delete_after" {
  description = "Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after`"
  type        = number
  default     = null
}

variable "rule_copy_action_lifecycle" {
  description = "The lifecycle defines when a protected resource is copied over to a backup vault and when it expires."
  type        = map(any)
  default     = {}
}

variable "rule_copy_action_destination_vault_arn" {
  description = "An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup."
  type        = string
  default     = null
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

variable "selection_tag_type" {
  description = "An operation, such as StringEquals, that is applied to a key-value pair used to filter resources in a selection"
  type        = string
  default     = null
}

variable "selection_tag_key" {
  description = "The key in a key-value pair"
  type        = string
  default     = null
}

variable "selection_tag_value" {
  description = "The value in a key-value pair"
  type        = string
  default     = null
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
