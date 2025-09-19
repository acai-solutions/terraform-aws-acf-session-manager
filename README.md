# AWS SSM Session Manager Terraform module

<!-- LOGO -->
<a href="https://acai.gmbh">    
  <img src="https://github.com/acai-solutions/acai.public/raw/main/logo/logo_github_readme.png" alt="acai logo" title="ACAI" align="right" height="75" />
</a>

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url]
[![documentation][acai-docs-shield]][acai-docs-url]  
![module-version-shield]
![terraform-version-shield]  
![trivy-shield]
![checkov-shield]

<!-- DESCRIPTION -->
[Terraform][terraform-url] module to deploy AWS SSM Session Manager resources on [AWS][aws-url]

<!-- ARCHITECTURE -->
## Architecture

![architecture][architecture]

<!-- FEATURES -->
## Features

* S3-Logging in Central Account
* CloudWatch Logging to local Account



<!-- AUTHORS -->
## Authors

This module is maintained by [ACAI GmbH][acai-url].

<!-- LICENSE -->
## License

See [LICENSE][license-url] for full details.

<!-- COPYRIGHT --><br />
<br />
<p align="center">Copyright &copy; 2024 ACAI GmbH</p>


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.session_logs_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.session_manager_logs_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.session_manager_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.session_manager_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.session_manager_logs_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_object_lock_configuration.session_manager_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_ownership_controls.session_manager_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.access_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.session_manager_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.session_manager_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.session_manager_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.access_logs_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.session_manager_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.access_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.session_manager_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.session_manager_logs_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of tags to assign to the resources in this module. | `map(string)` | `{}` | no |
| <a name="input_session_manager_settings"></a> [session\_manager\_settings](#input\_session\_manager\_settings) | Session Manager Settings for multi-account setup. | <pre>object({<br/>    central_logging = object({<br/>      kms_cmk = optional(object(<br/>        {<br/>          alias_name                    = optional(string, "session-manager-logs-key")<br/>          deletion_window_in_days       = optional(number, 7)<br/>          privileged_principal_arn_list = optional(list(string), []) # List of ARNs that need full access to the central resources<br/>        }),<br/>        {<br/>          alias_name                    = "session-manager-logs-key"<br/>          deletion_window_in_days       = 7<br/>          privileged_principal_arn_list = []<br/>        }<br/>      )<br/>      s3_bucket = object({<br/>        bucket_name   = string<br/>        force_destroy = optional(bool, false)<br/>        lifecycle_rules = optional(object(<br/>          {<br/>            transition_glacier_days    = optional(number, 90)<br/>            transition_noncurrent_days = optional(number, 30)<br/>            expiration_days            = optional(number, 365)<br/>            expiration_noncurrent_days = optional(number, 90)<br/>          }),<br/>          {<br/>            transition_glacier_days    = 90<br/>            transition_noncurrent_days = 30<br/>            expiration_days            = 365<br/>            expiration_noncurrent_days = 90<br/>          }<br/>        )<br/>      })<br/>    })<br/>  })</pre> | <pre>{<br/>  "central_logging": {<br/>    "kms_cmk": {<br/>      "alias_name": "session-manager-logs-key",<br/>      "deletion_window_in_days": 7<br/>    },<br/>    "s3_bucket": {<br/>      "bucket_name": "session-manager-logs",<br/>      "lifecycle_rules": {<br/>        "expiration_days": 365,<br/>        "expiration_noncurrent_days": 90,<br/>        "transition_glacier_days": 90,<br/>        "transition_noncurrent_days": 30<br/>      },<br/>      "versioning_configuration": "Enabled"<br/>    }<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_session_manager_to_write"></a> [session\_manager\_to\_write](#output\_session\_manager\_to\_write) | Session Manager Output. |
<!-- END_TF_DOCS -->

<!-- MARKDOWN LINKS & IMAGES -->
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[acai-docs-shield]: https://img.shields.io/badge/documentation-docs.acai.gmbh-CB224B?style=flat
[acai-url]: https://acai.gmbh
[acai-docs-url]: https://docs.acai.gmbh
[module-version-shield]: https://img.shields.io/badge/module_version-1.2.5-CB224B?style=flat
[module-release-url]: ./releases
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.10-blue.svg?style=flat&color=blueviolet
[trivy-shield]: https://img.shields.io/badge/trivy-passed-green
[checkov-shield]: https://img.shields.io/badge/checkov-passed-green
[architecture]: ./docs/terraform-aws-acf-session-manager.png
[example-complete-url]: ./examples/complete
[license-url]: ./LICENSE.md
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.com
