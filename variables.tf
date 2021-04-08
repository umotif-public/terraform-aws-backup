
##################
# AWS Backup vault
##################
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

#################
# AWS Backup plan
#################
variable "plan_name" {
  description = "The display name of a backup plan"
  type        = string
}

variable "rules" {
  description = "A list of rules mapping rule configurations for a backup plan"
  type        = any
  default     = []
}

variable "advanced_backup_settings" {
  description = "An object that specifies backup options for each resource type"
  type        = any
  default     = []
}

# Selection
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

variable "iam_role_name" {
  description = "Name of IAM Role to associate to the Backup Plan"
  type        = string
  default     = null
}
