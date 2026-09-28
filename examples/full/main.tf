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
