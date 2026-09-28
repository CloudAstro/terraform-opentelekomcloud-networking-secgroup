variable "name" {
  type        = string
  nullable    = false
  description = <<DESCRIPTION
* `name` - (Required) The name of the security group created by this module.

Example input:
```hcl
name = "sg-application"
```
DESCRIPTION

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty or contain only whitespace."
  }
}

variable "description" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `description` - (Optional) A description of the security group.

Example input:
```hcl
description = "Application security group"
```
DESCRIPTION
}

variable "delete_default_rules" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
* `delete_default_rules` - (Optional) Delete the automatically created security-group rules. Defaults to `false`. When enabled, define the required egress rules explicitly.

Example input:
```hcl
delete_default_rules = true
```
DESCRIPTION
}

variable "tenant_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
* `tenant_id` - (Optional) Project that owns the security group. Creating a group for another project requires the corresponding administrative permissions.

Example input:
```hcl
tenant_id = "00000000-0000-0000-0000-000000000001"
```
DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
* `timeouts` - (Optional) Security-group timeouts.
  * `delete` - (Optional) Maximum time to delete the security group.
  * `create` - (Deprecated) Retained for input compatibility; it is not passed to the provider and has no effect.

Example input:
```hcl
timeouts = {
  delete = "5m"
}
```
DESCRIPTION
}

variable "secgroup_rules" {
  type = map(object({
    description       = optional(string)
    direction         = string
    ethertype         = string
    protocol          = optional(string)
    port_range_min    = optional(number)
    port_range_max    = optional(number)
    remote_ip_prefix  = optional(string)
    remote_group_id   = optional(string)
    security_group_id = optional(string)
    tenant_id         = optional(string)
    timeouts = optional(object({
      delete = optional(string)
    }))
  }))
  default     = null
  description = <<DESCRIPTION
Map of security-group rules, keyed by stable rule names. Null or an empty map creates no managed rules.

* `description` - (Optional) Description of the rule.
* `direction` - (Required) `ingress` or `egress`.
* `ethertype` - (Required) `IPv4` or `IPv6`.
* `protocol` - (Optional) IP protocol, such as `tcp`, `udp` or `icmp`. Omit for all protocols. Required when specifying ports.
* `port_range_min`, `port_range_max` - (Optional) Inclusive TCP/UDP port range, using whole numbers from 1 to 65535. Omit both for all ports. ICMP uses protocol-specific type/code values; see the provider documentation.
* `remote_ip_prefix` - (Optional) Remote IPv4 or IPv6 CIDR. Mutually exclusive with `remote_group_id`.
* `remote_group_id` - (Optional) Remote security group in the same project. If neither remote selector is set, the module uses its own security group, preserving the existing self-group default.
* `security_group_id` - (Optional) Group to which this rule belongs. Defaults to the group created by this module. The module always creates its own group even when a rule targets an existing group.
* `tenant_id` - (Optional) Project for this rule. Set explicitly when needed; it does not inherit the module's `tenant_id` input.
* `timeouts.delete` - (Optional) Maximum time to delete this rule.

Example input:
```hcl
secgroup_rules = {
  ssh_ingress = {
    direction        = "ingress"
    ethertype        = "IPv4"
    protocol         = "tcp"
    port_range_min   = 22
    port_range_max   = 22
    remote_ip_prefix = "203.0.113.0/24"
  }
}
```
DESCRIPTION

  validation {
    condition = alltrue([
      for rule in(var.secgroup_rules == null ? {} : var.secgroup_rules) :
      try(contains(["ingress", "egress"], rule.direction) && contains(["IPv4", "IPv6"], rule.ethertype), false)
    ])
    error_message = "Each rule must specify direction ingress/egress and ethertype IPv4/IPv6."
  }

  validation {
    condition = alltrue([
      for rule in(var.secgroup_rules == null ? {} : var.secgroup_rules) :
      try(rule.remote_ip_prefix == null || rule.remote_group_id == null, false)
    ])
    error_message = "Specify remote_ip_prefix or remote_group_id for a rule, not both."
  }

  validation {
    condition = alltrue([
      for rule in(var.secgroup_rules == null ? {} : var.secgroup_rules) :
      try(contains(["tcp", "udp", "6", "17"], coalesce(rule.protocol, "all")) ? (
        rule.port_range_min == null && rule.port_range_max == null ? true : (
          rule.port_range_min >= 1 && rule.port_range_max <= 65535 &&
          rule.port_range_min <= rule.port_range_max &&
          floor(rule.port_range_min) == rule.port_range_min && floor(rule.port_range_max) == rule.port_range_max
        )
      ) : true, false)
    ])
    error_message = "TCP/UDP rules must omit both ports or specify an ordered whole-number range from 1 to 65535."
  }
}
