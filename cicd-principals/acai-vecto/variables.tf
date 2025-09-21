# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


variable "cloudwatch_loggroup" {
  description = "Configuration settings for CloudWatch LogGroup."
  type = object({
    loggroup_name = optional(string, "org-cloudtrail-logs")
    iam_role_name = optional(string, "cloudtrail-role")
    iam_role_path = optional(string, "/")
  })
  default = null
}

variable "s3_bucket" {
  description = "Configuration settings for core logging."
  type = object({
    bucket_name        = optional(string, null)
    bucket_name_prefix = optional(string, null)
    notification_to_sns = optional(object({
      sns_name = optional(string, "org-cloudtrail-bucket-notification")
    }), null)
  })

  validation {
    condition     = (var.s3_bucket.bucket_name == null ? var.s3_bucket.bucket_name_prefix != null : var.s3_bucket.bucket_name_prefix == null)
    error_message = "Either bucket_name or bucket_name_prefix must be provided, but not both."
  }

  validation {
    condition = alltrue([
      var.s3_bucket.bucket_name == null ? true : length(regexall("^[a-zA-Z0-9-]+$", var.s3_bucket.bucket_name)) > 0,
      var.s3_bucket.bucket_name_prefix == null ? true : length(regexall("^[a-zA-Z0-9-]+$", var.s3_bucket.bucket_name_prefix)) > 0
    ])
    error_message = "Both bucket_name and bucket_name_prefix must only contain alphanumeric characters and hyphens, if provided."
  }
}

variable "core_configuration" {
  description = "Written Org CloudTrail-Node of the Core Configuration"
  type = object({
    security = optional(object({
      org_cloudtrail = optional(object({
        cloudtrail_admin = object({
          cloudwatch_loggroup = object({
            kms_cmk_arn = optional(string, null)
          })
        })
        cloudtrail_bucket = object({
          kms_cmk_arn = string
        })
      }), null)
    }), null)
  })
  default = null
}
