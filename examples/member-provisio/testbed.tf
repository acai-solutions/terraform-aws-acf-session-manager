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
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
  alias  = "org_mgmt"
  assume_role {
    role_arn = "arn:aws:iam::471112796356:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Org-Mgmt Account
  }
}

provider "aws" {
  region = "eu-central-1"
  alias  = "core_logging"
  assume_role {
    role_arn = "arn:aws:iam::590183833356:role/OrganizationAccountAccessRole" // ACAI AWS Testbed Core Logging Account
  }
}

provider "aws" {
  region = "eu-central-1"
  alias  = "core_security"
  assume_role {
    role_arn = "arn:aws:iam::992382728088:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Core Security Account
  }
}

provider "aws" {
  region = "eu-central-1"
  alias  = "workload"
  assume_role {
    role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Workload Account
  }
}

provider "aws" {
  region = "us-east-2"
  alias  = "workload_use2"
  assume_role {
    role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Workload Account
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ BACKEND
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  backend "remote" {
    organization = "acai"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-testbed-2"
    }
  }
}
