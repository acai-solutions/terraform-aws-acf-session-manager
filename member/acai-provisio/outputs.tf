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
  value = var.provisio_settings.provisio_package_name
}

output "tf_module_name" {
  value = local.tf_module_name
}

output "provisio_package_files" {
  value = local.provisio_package_files
}
