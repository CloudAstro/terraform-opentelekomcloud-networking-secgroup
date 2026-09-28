# OpenTelekomCloud Networking Security Group Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

This module manages an OpenTelekomCloud security group and a map of security-group
rules using the Neutron v2 resources. It supports ingress and egress rules,
IPv4/IPv6, CIDR or security-group references, and configurable delete timeouts.

# Features

- **Security Group Management**: Creates a group with configurable name, description and default-rule handling.
- **Declarative Rules**: Creates rules from a map with stable Terraform resource keys.
- **Remote Selectors**: Supports CIDRs, explicit remote groups and the existing self-group default.
- **Protocol and Port Settings**: Supports all-protocol rules and protocol-specific port ranges.
- **Timeout Control**: Supports security-group and per-rule delete timeouts.

# Setup Requirements

Supply OTC credentials through the provider's supported environment variables, such
as `OS_USERNAME`, `OS_PASSWORD`, `OS_DOMAIN_NAME`, `OS_PROJECT_NAME` and `OS_REGION`.
The examples use the eu-de authentication endpoint; adjust `provider.tf` for your
region. Do not commit credentials.

# Example Usage

The [default example](examples/default/main.tf) creates a group with the cloud's
default rules. The [full example](examples/full/main.tf) creates a trusted group
and an application group with explicit IPv4/IPv6 rules and delete timeouts:
