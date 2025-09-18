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

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.47"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_organizations_organization" "org" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = merge(
    var.resource_tags,
    {
      "module_provider" = "ACAI GmbH",
      "module_name"     = "terraform-aws-acf-session-manager",
      "module_version"  = /*inject_version_start*/ "1.2.5" /*inject_version_end*/
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ KMS CMK
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "session_manager_logs_key" {
  description             = "KMS key for encrypting Session Manager logs"
  enable_key_rotation     = true
  deletion_window_in_days = var.session_manager_settings.central_logging.kms_cmk.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.session_manager_logs_key.json
  tags = merge(local.resource_tags, {
    Name = "session-manager-logs-key"
  })
}

resource "aws_kms_alias" "session_logs_key_alias" {
  name          = "alias/${var.session_manager_settings.central_logging.kms_cmk.alias_name}"
  target_key_id = aws_kms_key.session_manager_logs_key.id
}

data "aws_iam_policy_document" "session_manager_logs_key" {
  #checkov:skip=CKV_AWS_356 : Resource policy
  #checkov:skip=CKV_AWS_109
  #checkov:skip=CKV_AWS_111
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow S3 Access"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.org.id]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
  statement {
    sid    = "Allow Organization Access for SSM"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.org.id]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalServiceName"
      values   = ["ssm.amazonaws.com"]
    }
  }
  dynamic "statement" {
    for_each = length(var.session_manager_settings.central_logging.kms_cmk.privileged_principal_arn_list) > 0 ? [1] : []

    content {
      sid    = "Allow Privileged Principals"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.session_manager_settings.central_logging.kms_cmk.privileged_principal_arn_list
      }
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ]
      resources = ["*"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "session_manager_logs" {
  #checkov:skip=CKV2_AWS_61 : No lifecycle configuration for policy bucket
  #checkov:skip=CKV2_AWS_62 : No event notifications for policy bucket
  #checkov:skip=CKV_AWS_144 : No Cross-Region Bucket replication
  #checkov:skip=CKV_AWS_145 : Bucket is encrypted - see below
  bucket        = var.session_manager_settings.central_logging.s3_bucket.bucket_name
  force_destroy = var.session_manager_settings.central_logging.s3_bucket.force_destroy
  tags          = local.resource_tags
}

resource "aws_s3_bucket_versioning" "session_manager_logs" {
  bucket = aws_s3_bucket.session_manager_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "session_manager_logs" {
  bucket = aws_s3_bucket.session_manager_logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.session_manager_logs_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "session_manager_logs" {
  bucket = aws_s3_bucket.session_manager_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "session_manager_logs" {
  bucket = aws_s3_bucket.session_manager_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "session_manager_logs" {
  depends_on          = [aws_s3_bucket_versioning.session_manager_logs]
  bucket              = aws_s3_bucket.session_manager_logs.id
  object_lock_enabled = "Enabled"

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = var.session_manager_settings.central_logging.s3_bucket.lifecycle_rules.expiration_days
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "session_manager_logs" {
  #checkov:skip=CKV_AWS_145 : Bucket is encrypted - see below
  bucket = aws_s3_bucket.session_manager_logs.id

  rule {
    id     = "log_lifecycle"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    transition {
      days          = var.session_manager_settings.central_logging.s3_bucket.lifecycle_rules.transition_glacier_days
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = var.session_manager_settings.central_logging.s3_bucket.lifecycle_rules.transition_noncurrent_days
      storage_class   = "GLACIER"
    }

    expiration {
      days = var.session_manager_settings.central_logging.s3_bucket.lifecycle_rules.expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.session_manager_settings.central_logging.s3_bucket.lifecycle_rules.expiration_noncurrent_days
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ S3 BUCKET POLICY
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "session_manager_bucket" {
  statement {
    sid    = "AllowPutObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${aws_s3_bucket.session_manager_logs.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.org.id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    sid    = "AllowGetObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.session_manager_logs.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.org.id]
    }
  }
  statement {
    sid    = "AllowReadEncryptionSettings"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.session_manager_logs.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.org.id]
    }
  }
  /*statement {
    sid    = "EnforceSSLOnly"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.session_manager_logs.arn}/*",
      aws_s3_bucket.session_manager_logs.arn
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }*/
}

resource "aws_s3_bucket_policy" "session_manager_logs" {
  bucket = aws_s3_bucket.session_manager_logs.id
  policy = data.aws_iam_policy_document.session_manager_bucket.json
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ ACCESS LOGS S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "access_logs" {
  #checkov:skip=CKV2_AWS_61 : No lifecycle configuration for policy bucket
  #checkov:skip=CKV2_AWS_62 : No event notifications for policy bucket
  #checkov:skip=CKV_AWS_144 : No Cross-Region Bucket replication
  #checkov:skip=CKV_AWS_145 : Bucket is encrypted - see below
  bucket = "${var.session_manager_settings.central_logging.s3_bucket.bucket_name}-accesslogs"
  tags   = local.resource_tags
}


resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.session_manager_logs_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "access_logs_versioning" {
  bucket = aws_s3_bucket.access_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "access_logs_policy" {
  statement {
    sid    = "AllowS3LogDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.access_logs.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs_policy" {
  bucket = aws_s3_bucket.access_logs.id
  policy = data.aws_iam_policy_document.access_logs_policy.json
}

resource "aws_s3_bucket_logging" "session_manager_logs_logging" {
  bucket        = aws_s3_bucket.session_manager_logs.id
  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "session-manager-logs/"
}
