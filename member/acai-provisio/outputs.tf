# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


output "package_id" {
  description = "The unique ID of the PROVISIO package"
  value       = "${var.provisio_settings.package_name}-${random_uuid.module_id.result}"
}

output "package_name" {
  description = "The name of the PROVISIO package"
  value       = var.provisio_settings.package_name
}

output "tf_module_name" {
  description = "The Terraform module name"
  value       = local.tf_module_name
}

output "tf_provider_regions" {
  description = "The list of Terraform provider regions"
  value       = local.all_regions
}

output "package_files" {
  description = "The list of files included in the PROVISIO package"
  value       = local.package_files
}
