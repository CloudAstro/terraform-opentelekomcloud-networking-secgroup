resource "opentelekomcloud_networking_secgroup_v2" "networking_secgroup" {
  name                 = var.name
  description          = var.description
  delete_default_rules = var.delete_default_rules
  tenant_id            = var.tenant_id

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      delete = timeouts.value.delete
    }
  }
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "networking_secgroup_rule" {
  for_each = var.secgroup_rules != null ? var.secgroup_rules : {}

  description    = each.value.description
  direction      = each.value.direction
  ethertype      = each.value.ethertype
  protocol       = each.value.protocol
  port_range_max = each.value.port_range_max
  port_range_min = each.value.port_range_min
  remote_group_id = each.value.remote_ip_prefix != null ? null : (
    each.value.remote_group_id != null ? each.value.remote_group_id : opentelekomcloud_networking_secgroup_v2.networking_secgroup.id
  )
  remote_ip_prefix  = each.value.remote_ip_prefix
  security_group_id = each.value.security_group_id != null ? each.value.security_group_id : opentelekomcloud_networking_secgroup_v2.networking_secgroup.id
  tenant_id         = each.value.tenant_id

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      delete = timeouts.value.delete
    }
  }
}
