# ACAI Cloud Foundation (ACF)
# Copyright (C) 2025 ACAI GmbH
# Licensed under AGPL v3
#
# This file is part of ACAI ACF.
# Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# For full license text, see LICENSE file in repository root.
# For commercial licensing, contact: contact@acai.gmbh


output "session_manager_to_write" {
  description = "Session Manager Output."
  value = {
    central_logging = {
      kms_cmk = {
        key_id  = aws_kms_key.session_manager_logs_key.id
        key_arn = aws_kms_key.session_manager_logs_key.arn
      }
      s3_bucket = {
        bucket_id  = aws_s3_bucket.session_manager_logs.id
        bucket_arn = aws_s3_bucket.session_manager_logs.arn
      }
    }
  }
}