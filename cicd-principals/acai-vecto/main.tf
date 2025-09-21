# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


locals {
  org_cloudtrail_bucket_kms_cmk_arn = var.core_configuration == null ? "" : (
    var.core_configuration.security == null ? "" : (
      var.core_configuration.security.org_cloudtrail == null ? "" : (
        var.core_configuration.security.org_cloudtrail.cloudtrail_bucket.kms_cmk_arn == null ? "" : (
          var.core_configuration.security.org_cloudtrail.cloudtrail_bucket.kms_cmk_arn
        )
      )
    )
  )
}


data "template_file" "session_manager_bucket" {
  template = file("${path.module}/session_manager_bucket.yaml.tftpl")
  vars = {
    bucket_prefix                   = var.s3_bucket.bucket_name == null ? var.s3_bucket.bucket_prefix : var.s3_bucket.bucket_name
    bucket_notification_to_sns_name = var.s3_bucket.notification_to_sns == null ? "" : var.s3_bucket.notification_to_sns.sns_name
    kms_cmk_arn                     = local.org_cloudtrail_bucket_kms_cmk_arn
  }
}


output "cf_template_map" {
  value = {
    "session_manager_bucket.yaml.tftpl" = replace(data.template_file.session_manager_bucket.rendered, "$$$", "$$")
  }
}
