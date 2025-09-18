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

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
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
