output "networking_secgroup" {
  value       = opentelekomcloud_networking_secgroup_v2.networking_secgroup
  description = <<DESCRIPTION
The security-group resource created by this module, including its ID and name.

Example output:
```hcl
output "security_group_id" {
  value = module.sg.networking_secgroup.id
}
```
DESCRIPTION
}

output "networking_secgroup_rule" {
  value       = opentelekomcloud_networking_secgroup_rule_v2.networking_secgroup_rule
  description = <<DESCRIPTION
Map of managed rule resources keyed by the same names as `secgroup_rules`. Select a rule by key before accessing its attributes.

Example output:
```hcl
output "https_rule_id" {
  value = module.sg.networking_secgroup_rule["https_v4"].id
}
```
DESCRIPTION
}
