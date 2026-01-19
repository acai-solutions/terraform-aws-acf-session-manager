# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMPILE PROVISIO PACKAGES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = templatefile("${path.module}/templates/tags.tf.tftpl", {
    map_of_tags = merge(
      var.resource_tags,
      {
        "module_provider" = "ACAI GmbH",
        "module_name"     = "terraform-aws-acf-session-manager",
        "module_source"   = "github.com/acai-solutions/terraform-aws-acf-session-manager",
        "module_feature"  = "member",
        "module_version"  = /*inject_version_start*/ "1.2.5" /*inject_version_end*/
      }
    )
  })


  central_logging_enabled = var.session_manager_settings.central_logging != null ? true : false
  local_logging_enabled   = var.session_manager_settings.member_account.cloudwatch_logs != null ? true : false

  ssm_document_name            = var.session_manager_settings.member_account.ssm_preferences.document_name
  instance_profile_role_name   = var.session_manager_settings.member_account.instance_profile_role.name
  instance_profile_name        = var.session_manager_settings.member_account.instance_profile.name
  instance_profile_policy_name = var.session_manager_settings.member_account.instance_profile_policy_name
  log_group_name               = local.local_logging_enabled ? var.session_manager_settings.member_account.cloudwatch_logs.log_group_name : ""

  all_regions = sort(distinct(concat(
    [var.provisio_settings.target_regions.primary_region],
    var.provisio_settings.target_regions.secondary_regions
  )))
  tf_module_name = replace(var.provisio_settings.override_module_name == null ? var.provisio_settings.package_name : var.provisio_settings.override_module_name, "-", "_")

  package_files = merge(
    var.provisio_settings.import_resources ? ({
      "import.part" = templatefile("${path.module}/templates/import.part.tftpl", {
        tf_module_name               = local.tf_module_name
        primary_region               = var.provisio_settings.provisio_regions.primary_region
        all_regions                  = local.all_regions
        local_logging_enabled        = local.local_logging_enabled
        ssm_document_name            = local.ssm_document_name
        instance_profile_role_name   = local.instance_profile_role_name
        instance_profile_name        = local.instance_profile_name
        instance_profile_policy_name = local.instance_profile_policy_name
        log_group_name               = local.log_group_name
      })
      }) : ({
      "import.part" = ""
    }),
    {
      "main.tf" = templatefile("${path.module}/templates/main.tf.tftpl", {
        primary_region                                 = var.provisio_settings.provisio_regions.primary_region
        secondary_regions                              = var.provisio_settings.provisio_regions.secondary_regions
        central_logging_enabled                        = local.central_logging_enabled
        local_logging_enabled                          = local.local_logging_enabled
        central_s3_bucket_name                         = local.central_logging_enabled ? var.session_manager_settings.central_logging.s3_bucket.bucket_name : ""
        central_s3_bucket_arn                          = local.central_logging_enabled ? var.session_manager_settings.central_logging.s3_bucket.bucket_arn : ""
        central_s3_bucket_kms_arn                      = local.central_logging_enabled ? var.session_manager_settings.central_logging.kms_cmk.key_arn : ""
        ssm_document_name                              = local.ssm_document_name
        ssm_document_central_s3_bucket_prefix          = local.central_logging_enabled ? var.session_manager_settings.member_account.ssm_preferences.s3_prefix : ""
        ssm_document_run_as_enabled                    = var.session_manager_settings.member_account.ssm_preferences.run_as_enabled
        ssm_document_run_as_user                       = var.session_manager_settings.member_account.ssm_preferences.run_as_user
        instance_profile_role_name                     = local.instance_profile_role_name
        instance_profile_role_path                     = var.session_manager_settings.member_account.instance_profile_role.path
        instance_profile_role_additional_policy_grants = var.additional_ssm_policy_grants != null ? var.additional_ssm_policy_grants : ""
        instance_profile_name                          = local.instance_profile_name
        instance_profile_path                          = var.session_manager_settings.member_account.instance_profile.path
        instance_profile_policy_name                   = local.instance_profile_policy_name
        log_group_name                                 = local.log_group_name
        log_retention_in_days                          = local.local_logging_enabled ? var.session_manager_settings.member_account.cloudwatch_logs.log_retention_in_days : 10
        kms_deletion_window_in_days                    = local.local_logging_enabled ? var.session_manager_settings.member_account.cloudwatch_logs.kms_deletion_window_in_days : 7
        key_alias                                      = local.local_logging_enabled ? var.session_manager_settings.member_account.cloudwatch_logs.key_alias : ""
        resource_tags                                  = local.resource_tags
      }),
      "requirements.tf" = templatefile("${path.module}/templates/requirements.tf.tftpl", {
        all_regions          = local.all_regions
        terraform_version    = var.provisio_settings.terraform_version,
        provider_aws_version = var.provisio_settings.provider_aws_version,
      })
    }
  )
}
