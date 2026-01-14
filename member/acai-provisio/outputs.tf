# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


output "provisio_package_name" {
  description = "The name of the Provisio package"
  value       = var.provisio_settings.provisio_package_name
}

output "tf_module_name" {
  description = "The Terraform module name"
  value       = local.tf_module_name
}

output "provisio_package_files" {
  description = "The list of files included in the Provisio package"
  value       = local.provisio_package_files
}

output "target_regions" {
  description = "The sorted list of target regions including primary and secondary regions"
  value = sort(distinct(concat(
    [var.provisio_settings.provisio_regions.primary_region],
    var.provisio_settings.provisio_regions.secondary_regions,
  )))
}
