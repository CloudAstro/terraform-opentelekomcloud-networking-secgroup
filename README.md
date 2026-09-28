<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
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

```hcl
module "trusted" {
  source = "../.."
  name   = "sg-trusted"
}

module "sg" {
  source               = "../.."
  name                 = "sg-example"
  description          = "Application security group"
  delete_default_rules = true

  timeouts = {
    delete = "5m"
  }
  secgroup_rules = {
    https_v4 = {
      description     = "Allow HTTPS from the trusted security group"
      direction       = "ingress"
      ethertype       = "IPv4"
      protocol        = "tcp"
      port_range_min  = 443
      port_range_max  = 443
      remote_group_id = module.trusted.networking_secgroup.id
      timeouts = {
        delete = "5m"
      }
    }
    http_v4 = {
      description      = "Allow HTTP (IPv4) from Internet"
      direction        = "ingress"
      ethertype        = "IPv4"
      protocol         = "tcp"
      port_range_min   = 80
      port_range_max   = 80
      remote_ip_prefix = "0.0.0.0/0"
    }
    http_v6 = {
      description      = "Allow HTTP (IPv6) from Internet"
      direction        = "ingress"
      ethertype        = "IPv6"
      protocol         = "tcp"
      port_range_min   = 80
      port_range_max   = 80
      remote_ip_prefix = "::/0"
    }
    https_v6 = {
      description      = "Allow HTTPS (IPv6) from Internet"
      direction        = "ingress"
      ethertype        = "IPv6"
      protocol         = "tcp"
      port_range_min   = 443
      port_range_max   = 443
      remote_ip_prefix = "::/0"
    }
    egress_all_v4 = {
      description      = "Allow all egress (IPv4)"
      direction        = "egress"
      ethertype        = "IPv4"
      remote_ip_prefix = "0.0.0.0/0"
    }
    egress_all_v6 = {
      description      = "Allow all egress (IPv6)"
      direction        = "egress"
      ethertype        = "IPv6"
      remote_ip_prefix = "::/0"
    }
  }
}
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_opentelekomcloud"></a> [opentelekomcloud](#requirement\_opentelekomcloud) | >= 1.36.35 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opentelekomcloud"></a> [opentelekomcloud](#provider\_opentelekomcloud) | >= 1.36.35 |

## Resources

| Name | Type |
|------|------|
| [opentelekomcloud_networking_secgroup_rule_v2.networking_secgroup_rule](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [opentelekomcloud_networking_secgroup_v2.networking_secgroup](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/networking_secgroup_v2) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | * `name` - (Required) The name of the security group created by this module.<br/><br/>Example input:<pre>hcl<br/>name = "sg-application"</pre> | `string` | n/a | yes |
| <a name="input_delete_default_rules"></a> [delete\_default\_rules](#input\_delete\_default\_rules) | * `delete_default_rules` - (Optional) Delete the automatically created security-group rules. Defaults to `false`. When enabled, define the required egress rules explicitly.<br/><br/>Example input:<pre>hcl<br/>delete_default_rules = true</pre> | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | * `description` - (Optional) A description of the security group.<br/><br/>Example input:<pre>hcl<br/>description = "Application security group"</pre> | `string` | `null` | no |
| <a name="input_secgroup_rules"></a> [secgroup\_rules](#input\_secgroup\_rules) | Map of security-group rules, keyed by stable rule names. Null or an empty map creates no managed rules.<br/><br/>* `description` - (Optional) Description of the rule.<br/>* `direction` - (Required) `ingress` or `egress`.<br/>* `ethertype` - (Required) `IPv4` or `IPv6`.<br/>* `protocol` - (Optional) IP protocol, such as `tcp`, `udp` or `icmp`. Omit for all protocols. Required when specifying ports.<br/>* `port_range_min`, `port_range_max` - (Optional) Inclusive TCP/UDP port range, using whole numbers from 1 to 65535. Omit both for all ports. ICMP uses protocol-specific type/code values; see the provider documentation.<br/>* `remote_ip_prefix` - (Optional) Remote IPv4 or IPv6 CIDR. Mutually exclusive with `remote_group_id`.<br/>* `remote_group_id` - (Optional) Remote security group in the same project. If neither remote selector is set, the module uses its own security group, preserving the existing self-group default.<br/>* `security_group_id` - (Optional) Group to which this rule belongs. Defaults to the group created by this module. The module always creates its own group even when a rule targets an existing group.<br/>* `tenant_id` - (Optional) Project for this rule. Set explicitly when needed; it does not inherit the module's `tenant_id` input.<br/>* `timeouts.delete` - (Optional) Maximum time to delete this rule.<br/><br/>Example input:<pre>hcl<br/>secgroup_rules = {<br/>  ssh_ingress = {<br/>    direction        = "ingress"<br/>    ethertype        = "IPv4"<br/>    protocol         = "tcp"<br/>    port_range_min   = 22<br/>    port_range_max   = 22<br/>    remote_ip_prefix = "203.0.113.0/24"<br/>  }<br/>}</pre> | <pre>map(object({<br/>    description       = optional(string)<br/>    direction         = string<br/>    ethertype         = string<br/>    protocol          = optional(string)<br/>    port_range_min    = optional(number)<br/>    port_range_max    = optional(number)<br/>    remote_ip_prefix  = optional(string)<br/>    remote_group_id   = optional(string)<br/>    security_group_id = optional(string)<br/>    tenant_id         = optional(string)<br/>    timeouts = optional(object({<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | * `tenant_id` - (Optional) Project that owns the security group. Creating a group for another project requires the corresponding administrative permissions.<br/><br/>Example input:<pre>hcl<br/>tenant_id = "00000000-0000-0000-0000-000000000001"</pre> | `string` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | * `timeouts` - (Optional) Security-group timeouts.<br/>  * `delete` - (Optional) Maximum time to delete the security group.<br/>  * `create` - (Deprecated) Retained for input compatibility; it is not passed to the provider and has no effect.<br/><br/>Example input:<pre>hcl<br/>timeouts = {<br/>  delete = "5m"<br/>}</pre> | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_networking_secgroup"></a> [networking\_secgroup](#output\_networking\_secgroup) | The security-group resource created by this module, including its ID and name.<br/><br/>Example output:<pre>hcl<br/>output "security_group_id" {<br/>  value = module.sg.networking_secgroup.id<br/>}</pre> |
| <a name="output_networking_secgroup_rule"></a> [networking\_secgroup\_rule](#output\_networking\_secgroup\_rule) | Map of managed rule resources keyed by the same names as `secgroup_rules`. Select a rule by key before accessing its attributes.<br/><br/>Example output:<pre>hcl<br/>output "https_rule_id" {<br/>  value = module.sg.networking_secgroup_rule["https_v4"].id<br/>}</pre> |

## Modules

No modules.

## 🌐 Additional Information

The module always creates a security group. A rule's optional `security_group_id`
can point at an existing group, but this does not suppress creation of the module's
own group. Rule outputs are maps: use
`module.sg.networking_secgroup_rule["https_v4"].id` to select a rule.

## 📚 Resources

- [Terraform Security Group Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/networking_secgroup_v2)
- [Terraform Security Group Rule Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/networking_secgroup_rule_v2)
- [Terraform OpenTelekomCloud Provider](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs)
- [Contributing](CONTRIBUTING.md)

## ⚠️ Notes

- Use either `remote_ip_prefix` or `remote_group_id` per rule. When both are omitted, the remote selector defaults to the group created by this module; it does not mean unrestricted access.
- Explicit `remote_group_id` values are now honored. Older code ignored them and substituted the module's group. Review replacement plans for existing rules that supplied this input.
- TCP/UDP ports must be within 1–65535. Omit both port values for all ports; use protocol-specific values for ICMP instead of TCP/UDP rules.
- Match the remote CIDR's address family to `ethertype`.
- When deleting default rules, explicitly declare required egress access. The full example permits public web traffic and unrestricted egress for demonstration; adjust it for your application.
- Stable rule-map keys preserve resource addresses. Renaming a key replaces the corresponding rule unless the caller performs an explicit state migration.
- Current resource addresses and output names are unchanged. Automatic migration from the older resource names ending in `_v2` is not included; existing consumers using those state addresses must migrate them before upgrading.
- The group-level `timeouts.create` input is retained for compatibility but has no effect. Only delete timeouts are configured.
- Configure project ownership consistently: per-rule `tenant_id` is independent of the group-level input.
- Generate this README with `terraform-docs .`; edit `_header.md`, `_footer.md` and Terraform descriptions. GitHub workflows assume this directory is the root of a standalone repository.
- No public registry release has been created by this preparation. The intended module address is `CloudAstro/networking-secgroup/opentelekomcloud` once published.

## 🧾 License

This module is released under the **Apache 2.0 License**, as declared in its existing
documentation. See [LICENSE](LICENSE) for the full text.
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->