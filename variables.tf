# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


variable "session_manager_settings" {
  description = "Session Manager Settings for multi-account setup."
  type = object({
    central_logging = object({
      kms_cmk = optional(object(
        {
          alias_name                    = optional(string, "session-manager-logs-key")
          deletion_window_in_days       = optional(number, 7)
          privileged_principal_arn_list = optional(list(string), []) # List of ARNs that need full access to the central resources
        }),
        {
          alias_name                    = "session-manager-logs-key"
          deletion_window_in_days       = 7
          privileged_principal_arn_list = []
        }
      )
      s3_bucket = object({
        bucket_name   = string
        force_destroy = optional(bool, false)
        lifecycle_rules = optional(object(
          {
            transition_glacier_days    = optional(number, 90)
            transition_noncurrent_days = optional(number, 30)
            expiration_days            = optional(number, 365)
            expiration_noncurrent_days = optional(number, 90)
          }),
          {
            transition_glacier_days    = 90
            transition_noncurrent_days = 30
            expiration_days            = 365
            expiration_noncurrent_days = 90
          }
        )
      })
    })
  })
  default = {
    central_logging = {
      kms_cmk = {
        alias_name              = "session-manager-logs-key"
        deletion_window_in_days = 7
      }
      s3_bucket = {
        bucket_name              = "session-manager-logs"
        versioning_configuration = "Enabled"
        lifecycle_rules = {
          transition_glacier_days    = 90
          transition_noncurrent_days = 30
          expiration_days            = 365
          expiration_noncurrent_days = 90
        }
      }
    }
  }
}



# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}
