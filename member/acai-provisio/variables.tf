# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


variable "provisio_settings" {
  description = "ACAI PROVISIO settings"
  type = object({
    provisio_package_name = optional(string, "aws-session-manager")
    override_module_name  = optional(string, null)
    provisio_regions = object({
      primary_region    = string
      secondary_regions = list(string)
    })
    import_resources = optional(bool, false)
  })
}

variable "session_manager_settings" {
  description = "Specification of the member resources"
  type = object({
    central_logging = optional(object({
      kms_cmk = object({
        key_arn = string
      })
      s3_bucket = object({
        bucket_name = string
        bucket_arn  = string
      })
    }), null)
    member_account = optional(object(
      {
        ssm_preferences = optional(object(
          {
            document_name   = optional(string, "SSM-SessionManagerRunShell")
            document_format = optional(string, "JSON")
            run_as_enabled  = optional(bool, false)
            run_as_user     = optional(string, "")
            s3_prefix       = optional(string, "session-logs/")
          }),
          {
            document_name   = "SSM-SessionManagerRunShell"
            document_format = "JSON"
            run_as_enabled  = false
            run_as_user     = ""
            s3_prefix       = "session-logs/"
          }
        )
        instance_profile_role = optional(object({
          name = optional(string, "session-manager-instance-profile-role")
          path = optional(string, "/")
          }),
          {
            name = "session-manager-instance-profile-role"
            path = "/"
          }
        )
        instance_profile = optional(object(
          {
            name = optional(string, "session-manager-instance-profile")
            path = optional(string, "/")
          }),
          {
            name = "session-manager-instance-profile"
            path = "/"
          }
        )
        instance_profile_policy_name = optional(string, "session-manager-instance-profile-policy")
        cloudwatch_logs = optional(object({
          log_group_name              = optional(string, "/aws/session-manager/logs")
          log_retention_in_days       = optional(number, 30)
          key_alias                   = optional(string, "session-manager-logs-key")
          kms_deletion_window_in_days = optional(number, 30)
        }), null)
      }),
      {
        ssm_preferences = {
          document_name   = "SSM-SessionManagerRunShell"
          document_format = "JSON"
          run_as_enabled  = false
          run_as_user     = ""
          s3_prefix       = "session-logs/"
        }
        instance_profile = {
          name = "session-manager-instance-role"
          path = "/"
        }
        cloudwatch_logs = null
      }
  ) })
}

variable "additional_ssm_policy_grants" {
  description = "Additial Policy Statemtent for the SSM Policy."
  default     = null
}

variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}
