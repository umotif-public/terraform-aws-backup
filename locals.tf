locals {
  rule = var.rule_name == null ? [] : [
    {
      name              = var.rule_name
      target_vault_name = var.vault_name != null ? var.vault_name : "Default"
      schedule          = var.rule_schedule
      start_window      = var.rule_start_window
      completion_window = var.rule_completion_window
      lifecycle = var.rule_lifecycle_cold_storage_after == null ? {} : {
        cold_storage_after = var.rule_lifecycle_cold_storage_after
        delete_after       = var.rule_lifecycle_delete_after
      }
      recovery_point_tags = var.rule_recovery_point_tags
    }
  ]

  rules = concat(local.rule, var.rules)

  selection = var.selection_name == null ? [] : [
    {
      name      = var.selection_name
      resources = var.selection_resources
      selection_tag = var.selection_tag_type == null ? {} : {
        type  = var.selection_tag_type
        key   = var.selection_tag_key
        value = var.selection_tag_value
      }
    }
  ]

  selections = concat(local.selection, var.selections)

  depends_on = [aws_iam_role_policy_attachment.main_custom_policy_attach]
}
