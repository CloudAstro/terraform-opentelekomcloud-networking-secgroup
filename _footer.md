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
