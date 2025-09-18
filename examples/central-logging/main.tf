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
# ¦ VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  regions_settings = {
    primary_region    = "eu-central-1"
    secondary_regions = ["us-east-2"]
  }
  session_manager_settings = {
    central_logging = {
      kms_cmk = {
        alias_name              = "session-manager-logs-key"
        deletion_window_in_days = 7
      }
      s3_bucket = {
        bucket_name              = "session-manager-logs-${data.aws_caller_identity.current.account_id}"
        force_destroy            = true
        versioning_configuration = "Enabled"
        lifecycle_rules = {
          transition_glacier_days    = 90
          transition_noncurrent_days = 30
          expiration_days            = 365
          expiration_noncurrent_days = 90
        }
      }
    }
    member_account = {
      ssm_preferences = {
        document_name = "SSM-SessionManagerRunShell"
      }
      instance_profile_role = {
        name = "Platform_SSM_Service_Role"
        path = "/"
      }
      instance_profile = {
        name = "Platform_SSM_Service_InstanceProfile"
        path = "/"
      }
      instance_profile_policy_name = "Platform_SSM_Service_Policy"
      cloudwatch_logs = {
        log_group_name = "/aws/platform-session-manager/logs"
        key_alias      = "platform-session-manager-logs-key"
      }
    }
  }
}

module "aggregation" {
  source = "../../"

  session_manager_settings = local.session_manager_settings
  providers = {
    aws = aws.core_logging
  }
}

module "member_files" {
  source = "../../member/acai-provisio"

  provisio_settings = {
    provisio_regions = local.regions_settings
  }
  session_manager_settings = merge(
    {
      central_logging = {
        kms_cmk = module.aggregation.session_manager_to_write.central_logging.kms_cmk
        s3_bucket = merge(
          local.session_manager_settings.central_logging.s3_bucket,
          module.aggregation.session_manager_to_write.central_logging.s3_bucket
        )
      }
    },
    {
      member_account = local.session_manager_settings.member_account
    }
  )
}


# Loop through the map and create a file for each entry
resource "local_file" "package_files" {
  for_each = module.member_files.provisio_package_files

  filename = "${path.module}/../member-provisio/rendered/${each.key}" # Each key becomes the filename
  content  = each.value                                               # Each value becomes the file content
}
